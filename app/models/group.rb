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
    response_hash = {}
    response_hash[:gr_name] = name
    response_hash[:gr_passwd] = "x"
    response_hash[:gr_gid] = gid
    response_hash[:gr_mem] = users.collect { |u| u.user_login_id}
    response_hash
  end

  def self.get_sysadmins_and_groups sysadmins
    groups = []
    sysadmins_login_ids = []
    sysadmins.each do |sysadmin|
      user = User.find(sysadmin)
      sysadmins_login_ids << user.user_login_id
      group = Group.find_by(name: user.user_login_id)
      groups << group.group_response if group.present?
    end

    sysadmin_group = {}

    group = Group.find_by(name: "sysadmins")
    sysadmins_login_ids = sysadmins_login_ids + group.users.collect {|u| u.user_login_id} if group.present?
    group_id = group.blank? ? 8999 : group.id


    sysadmin_group[:gr_gid] = group_id
    sysadmin_group[:gr_mem] = sysadmins_login_ids.uniq
    sysadmin_group[:gr_name] = "sysadmins"
    sysadmin_group[:gr_passwd] = "x"

    groups << sysadmin_group
    groups.to_json
  end
end
