class Group < ActiveRecord::Base
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
    if host_machines.count > 0
      host_machines.each do |host|
        if host.access_key.present?
          REDIS_CACHE.del ("G:" + host.access_key)
          REDIS_CACHE.del ("P:" + host.access_key)
          Rails.logger.info "hello #{host.name} #{host.access_key}"
        end
      end
    end
  end

  def add_admin user
    GroupAdmin.find_or_create_by(group_id: id, user: user)
  end

  def set_lower_case_name
    self.name = self.name.downcase
  end

  def add_gid
    self.gid = self.id + GID_CONSTANT
    self.save!
  end

  def self.get_name_response name
    response = REDIS_CACHE.get(GROUP_NAME_RESPONSE + name)
    if response.blank?
      group = Group.where(name: name).first
      group = [] if group.blank?
      response = group.group_response.to_json
      REDIS_CACHE.set(GROUP_NAME_RESPONSE + name, response)
      REDIS_CACHE.expire(GROUP_NAME_RESPONSE + name, REDIS_KEY_EXPIRY)
    end
    return JSON.parse(response, symbolize_names: true)
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
    return response
  end

  def self.response_array group_response
    response_array = []
    response_array <<  group_response
    response_array
  end

  def self.get_gid_response gid
    group = Group.where(gid: gid).first
    return [] if group.blank?
    group.group_response
  end

  def admin? user
    GroupAdmin.where(group_id: self, user_id: user).first.present?
  end

  def member? user
    users.exists? user.id
  end

  def group_response
    return Group.group_nss_response name
  end

  def self.group_nss_response name
    group_response = REDIS_CACHE.get( "UG:" + name)
    group_response = JSON.parse(group_response) if group_response.present?

    if group_response.blank?
      group = Group.find_by(name: name)
      if group.present?
        response_hash = {}
        response_hash[:gr_name] = group.name
        response_hash[:gr_passwd] = "x"
        response_hash[:gr_gid] = group.gid
        response_hash[:gr_mem] = group.users.collect { |u| u.user_login_id}
        REDIS_CACHE.set( "UG:" + group.name, response_hash.to_json)
        REDIS_CACHE.expire( "UG:" + group.name, REDIS_KEY_EXPIRY)
        group_response = response_hash
      end
    end
    return group_response
  end

  def self.get_sysadmins_and_groups sysadmins, default_admins = true
    groups, sysadmins_login_ids = Group.get_groups_for_host sysadmins
    groups << Group.get_default_sysadmin_group_for_host(sysadmins_login_ids, default_admins)
    groups.to_json
  end

  def self.get_groups_for_host sysadmins
    groups = []
    sysadmins_login_ids = []
    sysadmins.each do |sysadmin|
      user = User.from_cache(sysadmin)
      sysadmins_login_ids << user["user_login_id"]
      groups << Group.group_nss_response(user["user_login_id"])
    end
    [groups, sysadmins_login_ids]
  end

  def get_user_ids
    user_ids = REDIS_CACHE.get( "G_UID:" + name)
    user_ids = JSON.parse(user_ids) if user_ids.present?

    if user_ids.blank?
      user_ids = users.collect {|u| u.user_login_id}
      REDIS_CACHE.set( "G_UID:" + name, user_ids.to_json)
      REDIS_CACHE.expire( "G_UID:" + name, REDIS_KEY_EXPIRY)
    end
    return user_ids
  end

  def self.get_default_sysadmin_group_for_host sysadmins_login_ids, default_admins = true
    sysadmin_group = {}
    sysadmins = sysadmins_login_ids

    if default_admins
      group = Group.find_by(name: "sysadmins")
       
      if group.present?
        sysadmins = sysadmins + group.get_user_ids
      end
    end
    group_id = group.blank? ? 8999 : group.id

    sysadmin_group[:gr_gid] = group_id
    sysadmin_group[:gr_mem] = sysadmins.uniq 
    sysadmin_group[:gr_name] = "sysadmins"
    sysadmin_group[:gr_passwd] = "x"
    return sysadmin_group
  end
end
