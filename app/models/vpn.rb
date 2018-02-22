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
end
