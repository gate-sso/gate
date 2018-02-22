class Vpn < ActiveRecord::Base
  has_paper_trail
  belongs_to :user
  belongs_to :group

  has_many :vpn_group_associations
  has_many :groups, through: :vpn_group_associations

  has_many :vpn_group_user_associations
  has_many :users, through: :vpn_group_user_associations

  has_many :vpn_domain_name_servers
  has_many :vpn_search_domains
  has_many :vpn_supplemental_match_domains

  def self.administrator? user
    administrator = false
    Vpn.all.each do |vpn|
      group = vpn.groups.first
      if group.present? && group.group_admins.present?
        group.group_admins.each do |member|
          administrator = true if user == member
        end
      end
    end
    return administrator
  end

  def self.managed_vpns user
    vpns = []
    Vpn.all.each do |vpn|
      groups = vpn.groups
      if groups.present?
        group_admins = groups.first.group_admins
        if group_admins.present?
          group_admins.each do |group_admin|
            vpns << vpn if group_admin.user == user
          end
        end
      end
    end
    return vpns
  end

  def self.user_vpns user
    vpns = []
    Vpn.all.each do |vpn|
      if vpn.groups.present?
        vpn.groups.each do |group|
          if group.users.present?
            group.users.each do |member|
              vpns << vpn if member == user
            end
          end
        end
      end
    end
    return vpns
  end

  def migrate_to_new_group
    group_name = "#{name}_vpn_group".downcase.squish.gsub(" ", "_")
    group = Group.where(name: group_name).first
    if group.blank?
    #create a new group for VPN
    group = Group.create(name: group_name, description: "#{name} VPN Access group")
    #Assign VPN to group
    #get all vpn administrators
    admins = []
    groups.each do |admin_group|
      admin_group.group_admins.each do |group_admin|
        group.add_admin group_admin.user
      end
    end

    #get all vpn users
    #add all vpn users to new group
    users.each do |user|
      user.groups << group
    end
    group.save!
    group.vpns << self
    end
  end
end
