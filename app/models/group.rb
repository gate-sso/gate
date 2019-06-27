class Group < ApplicationRecord
  has_paper_trail

  has_many :group_admins, dependent: :destroy
  has_many :group_associations
  has_many :users, through: :group_associations

  has_many :vpn_group_associations
  has_many :vpns, through: :vpn_group_associations

  has_many :host_access_groups
  has_many :host_machines, through: :host_access_groups
  belongs_to :vpn

  validates_uniqueness_of :name, case_sensitive: false
  validates :name, presence: true

  before_create :set_lower_case_name
  acts_as_paranoid

  after_create :add_gid

  GID_CONSTANT = 9000

  def burst_host_cache
    if host_machines.count.positive?
      host_machines.each do |host|
        if host.access_key.present?
          REDIS_CACHE.del "#{GROUP_RESPONSE}:#{host.access_key}"
          REDIS_CACHE.del "#{PASSWD_RESPONSE}:#{host.access_key}"
          Rails.logger.info "hello #{host.name} #{host.access_key}"
        end
      end
    end
  end

  def add_admin(user)
    GroupAdmin.find_or_create_by(group_id: id, user: user)
  end

  def set_lower_case_name
    self.name = name.downcase
  end

  def add_gid
    self.gid = id + GID_CONSTANT
    save!
  end

  def self.get_name_response(name)
    response = REDIS_CACHE.get(GROUP_NSS_RESPONSE + name)
    if response.blank?
      group = Group.where(name: name).first
      group = [] if group.blank?
      response = group.group_response.to_json
      REDIS_CACHE.set(GROUP_NSS_RESPONSE + name, response)
      REDIS_CACHE.expire(GROUP_NSS_RESPONSE + name, REDIS_KEY_EXPIRY)
    end
    JSON.parse(response, symbolize_names: true)
  end

  def self.get_all_response
    response = REDIS_CACHE.get(GROUP_ALL_RESPONSE)
    if response.blank?
      response_array = []
      Group.all.includes(:users).each do |group|
        response_array << group.group_response
      end
      response = response_array.to_json
      REDIS_CACHE.set(GROUP_ALL_RESPONSE, response)
      REDIS_CACHE.expire(GROUP_ALL_RESPONSE, REDIS_KEY_EXPIRY)
    end
    response
  end

  def self.get_gid_response(gid)
    group = Group.where(gid: gid).first
    return [] if group.blank?

    group.group_response
  end

  def admin?(user)
    GroupAdmin.where(group_id: self, user_id: user).first.present?
  end

  def member?(user)
    users.exists? user.id
  end

  def self.generate_group_response(name, gid, members)
    {
      gr_name: name,
      gr_passwd: 'x',
      gr_gid: gid,
      gr_mem: members,
    }
  end

  def group_response
    Group.group_nss_response name
  end

  def self.group_nss_response(name)
    group_response = REDIS_CACHE.get("#{GROUP_NSS_RESPONSE}:#{name}")
    group_response = JSON.parse(group_response) if group_response.present?

    if group_response.blank?
      group = Group.find_by(name: name)
      if group.present?
        members = group.users.map(&:user_login_id)
        response_hash = Group.generate_group_response(group.name, group.gid, members)
        REDIS_CACHE.set("#{GROUP_NSS_RESPONSE}:#{group.name}", response_hash.to_json)
        REDIS_CACHE.expire("#{GROUP_NSS_RESPONSE}:#{group.name}", REDIS_KEY_EXPIRY)
        group_response = response_hash
      end
    end
    group_response
  end

  def self.get_sysadmins_and_groups(sysadmins, default_admins = true)
    sysadmins_login_ids = User.
      select(:user_login_id).
      where('id IN (?)', sysadmins).
      map(&:user_login_id)

    # TODO: extract to query object
    groups = Group.
      select(%(
        id,
        name,
        gid,
        (
          SELECT GROUP_CONCAT(user_login_id)
          FROM users
          INNER JOIN group_associations
            ON users.id = group_associations.user_id
          WHERE group_associations.group_id = groups.id
        ) AS members
      )).
      where('name IN (?)', sysadmins_login_ids).
      map do |group|
        members = group.members.split(',')
        Group.generate_group_response(group.name, group.gid, members)
      end
    groups << Group.get_default_sysadmin_group_for_host(sysadmins_login_ids, default_admins)
    groups.to_json
  end

  def get_user_ids
    user_ids = REDIS_CACHE.get("#{GROUP_UID_RESPONSE}:#{name}")
    user_ids = JSON.parse(user_ids) if user_ids.present?

    if user_ids.blank?
      user_ids = users.map(&:user_login_id)
      REDIS_CACHE.set("#{GROUP_UID_RESPONSE}:#{name}", user_ids.to_json)
      REDIS_CACHE.expire("#{GROUP_UID_RESPONSE}:#{name}", REDIS_KEY_EXPIRY)
    end
    user_ids
  end

  def self.get_default_sysadmin_group_for_host(sysadmins_login_ids, default_admins = true)
    sysadmins = sysadmins_login_ids

    if default_admins
      group = Group.find_by(name: 'sysadmins')

      if group.present?
        sysadmins = sysadmins + group.get_user_ids
      end
    end
    group_id = group.blank? ? 8999 : group.id

    sysadmin_group = Group.generate_group_response('sysadmins', group_id, sysadmins.uniq)
    sysadmin_group
  end

  def add_user(user_id)
    unless group_associations.map(&:user_id).include?(user_id)
      group_associations.create(user_id: user_id)
      burst_host_cache
    end
  end

  def remove_user(user_id)
    group_associations.where(user_id: user_id).delete_all
    burst_host_cache
  end
end
