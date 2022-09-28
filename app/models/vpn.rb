class Vpn < ApplicationRecord
  belongs_to :user
  belongs_to :group

  has_many = has_many :vpn_group_associations
  has_many :groups, through: :vpn_group_associations

  has_many :vpn_group_user_associations
  has_many :users, through: :vpn_group_user_associations

  has_many :vpn_domain_name_servers
  has_many :vpn_search_domains
  has_many :vpn_supplemental_match_domains

  def self.administrator?(user)
    vpn_group_ids = VpnGroupAssociation.select(:group_id).collect(&:group_id)
    managed_group_vpns = user.group_admin.where(group_id: vpn_group_ids)
    !managed_group_vpns.empty?
  end

  def self.managed_vpns(user)

    vpn_group_ids = VpnGroupAssociation.select(:group_id).collect(&:group_id)
    managed_group_vpn_ids = user.
      group_admin.
      select(:group_id).
      where(group_id: vpn_group_ids).
      collect(&:group_id)
    VpnGroupAssociation.where(group_id: managed_group_vpn_ids).collect(&:vpn).uniq
  end

  def self.user_vpns user

    vpn_group_ids = VpnGroupAssociation.select(:group_id).collect(&:group_id)
    user_group_vpn_ids = user.
      group_associations.
      select(:group_id).
      where(group_id: vpn_group_ids).
      collect(&:group_id)
    VpnGroupAssociation.where(group_id: user_group_vpn_ids).collect(&:vpn).uniq
  end

  def migrate_to_new_group
    group_name = "#{name}_vpn_group".downcase.squish.gsub(' ', '_')
    group = Group.where(name: group_name).first
    if group.blank?
      # create a new group for VPN
      group = Group.create(name: group_name, description: "#{name} VPN Access group")
      # Assign VPN to group
      # get all vpn administrators
      admins = []
      groups.each do |admin_group|
        admin_group.group_admins.each do |group_admin|
          group.add_admin group_admin.user
        end
      end

      # get all vpn users
      # add all vpn users to new group
      users.each do |user|
        user.groups << group
      end
      group.save!
      group.vpns << self
    end
  end
end
