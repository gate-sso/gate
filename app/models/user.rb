class User < ApplicationRecord
  has_paper_trail

  include MsChapAuth
  devise :timeoutable, :omniauthable, omniauth_providers: [:google_oauth2]
  has_many :hosts
  has_many :group_associations
  has_many :groups, through: :group_associations
  has_many :group_admin, dependent: :destroy
  has_one :access_token

  # TODO: Need to add the validations for the user model, right now a lot of tests fail due to enabling this
  # validates :first_name, :last_name, :mobile, :user_role, presence: true
  # validates :first_name, :last_name, format: { with: /[a-zA-Z]/}, allow_blank: true
  # validates :user_role, inclusion: { in: ENV['USER_ROLES'].split(',') }
  # validate :validate_email_domain
  validates :email, uniqueness: true

  validate :remove_default_admin, on: :update

  before_save :revoke_admin_when_inactive, on: :update
  before_save :set_deactivated_at_when_inactive, on: :update

  HOME_DIR = '/home'.freeze
  USER_SHELL = '/bin/bash'.freeze

  def self.add_user(first_name, last_name, user_role, domain)
    user = User.new(first_name: first_name, last_name: last_name, user_role: user_role)
    user.assign_attributes(
      user_login_id: "#{first_name.downcase}.#{last_name.downcase}",
      uid: user.generate_uid,
      email: "#{first_name.downcase}.#{last_name.downcase}@#{domain}",
      name: "#{first_name} #{last_name}"
    )
    user.save
    user.initialise_host_and_group if user.persisted?
    user
  end

  def generate_login_id
    email.split('@').first
  end

  def generate_uid(uid_buffer = 5000)
    uid_buffer = ENV['UID_BUFFER'].present? ? ENV['UID_BUFFER'].to_i : uid_buffer
    User.last.blank? ? uid_buffer : User.last.id.to_i + uid_buffer
  end

  def initialise_host_and_group
    host = Host.find_or_initialize_by(user: self)
    unless ENV['DEFAULT_HOST_PATTERN'].blank?
      host.host_pattern = ENV['DEFAULT_HOST_PATTERN']
    end
    hosts << host
    groups << Group.find_or_initialize_by(name: user_login_id)
  end

  def generate_two_factor_auth(force_create = false)
    if persisted? && (force_create || (!force_create && auth_key.blank?))
      self.auth_key = ROTP::Base32.random_base32
      totp = ROTP::TOTP.new(auth_key)
      self.provisioning_uri = totp.provisioning_uri "GoJek-C #{email}"
      save!
    end
  end

  def self.create_user(name, email)
    user = User.find_or_initialize_by(email: email)
    unless user.persisted?
      user.assign_attributes(
        name: name, user_login_id: user.generate_login_id, uid: user.generate_uid
      )
      user.admin = User.first.blank?
      user.initialise_host_and_group
      user.save! if user.valid?
    end
    user
  end

  def self.add_temp_user(name, email)
    email += "@#{ENV['GATE_HOSTED_DOMAIN']}"
    user = User.create_user(name, email)
    user.generate_two_factor_auth
    user.auth_key
  end

  def update_profile(attrs = {})
    allowed_keys = %w(public_key name product_name admin active)
    attrs = attrs.stringify_keys
    attrs = attrs.select { |k, v| allowed_keys.include?(k) && (v.present? || v.eql?(false)) }
    assign_attributes(attrs)
    if active.eql?(false) && deactivated_at.blank?
      self.deactivated_at = Time.current
    end
    save! if valid?
  end

  def name_email
    "#{name} (#{email})"
  end

  def self.get_sysadmins user_ids
    users = User.
      select(%Q(
        id,
        name,
        uid,
        user_login_id,
        (
          SELECT gid
          FROM groups
          INNER JOIN group_associations
            ON groups.id = group_associations.group_id
          WHERE group_associations.user_id = users.id
          AND groups.name = users.user_login_id
          LIMIT 1
        ) AS gid,
        (
          SELECT COUNT(gid)
          FROM groups
          INNER JOIN group_associations
            ON groups.id = group_associations.group_id
          WHERE group_associations.user_id = users.id
          AND groups.name = users.user_login_id
          LIMIT 1
        ) AS gid_count
      )).
      where(id: user_ids)
    users.map(&:user_passwd_response)
  end

  def purge!
    if !self.active
      self.group_associations.each{ |g| g.destroy }
    end
  end

  def self.includes_restricted_characters? input_string
    return false if input_string.include?('@') == false
    restricted_characters = [ ' ', '-', '*']
    status  = false

    restricted_characters.each do |char|
      break if status
      status = input_string.include?(char)
    end

    status
  end

  def self.check_email_address email_address
    !includes_restricted_characters?(email_address) && email_address.split("@").count == 2 ? true : false
  end

  def self.valid_domain? domain
    hosted_domains = ENV['GATE_HOSTED_DOMAINS'].split(',')
    hosted_domains.include?(domain)
  end

  def self.verify params
    addresses = params[:addresses]
    return false if addresses.empty?
    address_array = addresses.split


    user = User.get_user params[:user]
    return false if user.blank?

    return user.permitted_hosts? address_array
  end

  def self.authenticate_pam params
    addresses = params[:addresses]
    return false if addresses.empty?
    address_array = addresses.split

    email, token = get_user_pass_attributes params
    return false if email.blank? || token.blank?

    user_auth = find_and_check_user email, token
    return check_user_host(email, address_array) if user_auth

    return user_auth
  end

  def self.check_user_host email, address_array
    user = User.get_user email
    return user.permitted_hosts? address_array
  end

  def permitted_vpns? address_array
    address_array.each do |host_address|
      Vpn.user_vpns(self).each do |vpn|
        return true if vpn.ip_address == host_address
      end
    end
    return false
  end

  def permitted_hosts? address_array
    address_array.each do |host_address|
      host_name = nil
      begin
        host_name = Resolv.getname(host_address)
      rescue
        Rails.logger.info "Can't resolve name"
      end
      host_name = host_address if host_name.blank?
      hosts.each do |host|
        return true if /^#{host.host_pattern}/.match(host_name).to_s.present?
      end
    end
    return false
  end

  def self.authenticate_cas encoded_string
    username_password = Base64.decode64 encoded_string.split(" ")[1]
    username = username_password.split(':').first
    password = username_password.split(':').last

    if User.find_and_check_user username, password
      return username
    else
      return nil
    end
  end


  def self.authenticate params
    email, token = User.get_user_pass_attributes params
    return false if email.blank? || token.blank?
    return User.find_and_check_user email, token
  end

  def self.get_user user_login_id
    return User.where(user_login_id: user_login_id, active: true).first
  end

  def self.find_and_validate_saml_user(email, password, app_name)
    query = 'users.email = ? and users.active = ? and groups.name = ?'
    users = User.joins(:groups).where(query, email, true, app_name)
    if users.present?
      users.first.valid_otp?(password) ? users.first : false
    else
      false
    end
  end

  def valid_otp?(password)
    user_key = "#{id}:#{Time.now.hour}"
    request_count = REDIS_CACHE.incrby user_key, 1
    REDIS_CACHE.expire user_key, 3600
    return false if request_count > RATE_LIMIT
    password.eql?(ROTP::TOTP.new(self.auth_key).now)
  end

  def self.find_and_check_user email, token
    user = User.get_user email
    return false if user.blank?
    return false if !user.active
    user_key = "#{user.id}:#{Time.now.hour}"
    request_count = REDIS_CACHE.incrby user_key, 1
    REDIS_CACHE.expire user_key, 3600
    return false if request_count > RATE_LIMIT
    token == ROTP::TOTP.new(user.auth_key).now
  end

  def self.get_user_pass_attributes params
    token = params[:token].present? ? params[:token] : params[:password]
    email = params[:email].present? ? params[:email] : params[:user]
    return [nil, nil] if email.blank? || token.blank?
    [email, token]
  end


  def self.get_shadow_name_response name
    user = User.where(name: name).first
    return nil if user.blank?

    user.get_shadow_hash
  end

  def get_shadow_hash
    shadow_hash = {}
    shadow_hash[:sp_namp] = user_login_id
    shadow_hash[:sp_pwdp] = "X"
    shadow_hash[:sp_lstchg] = updated_at.to_i
    shadow_hash[:sp_min] = 0
    shadow_hash[:sp_max] = 99999
    shadow_hash[:sp_warn] = 7
    shadow_hash[:sp_inact]= nil
    shadow_hash[:sp_expire] = nil
    shadow_hash[:sp_flag] = nil
    shadow_hash
  end

  def self.get_all_shadow_response
    user_array = []
    User.all.each do |user|
      user_array << user.get_shadow_hash
    end
    user_array
  end

  def self.get_all_passwd_response
    user_array = []
    User.all.each do |user|
      user_array << user.user_passwd_response
    end
    user_array
  end

  def self.get_passwd_name_response name
    user = User.where("email like ?", "#{name}@%").first
    return [] if user.blank?
    user.user_passwd_response
  end

  def self.response_array response
    user_response = []
    user_response << response
    user_response
  end

  def self.find_active_user_by_email(email)
    User.where(email: email, active: true).first
  end

  def group_names_list
    self.groups.map(&:name)
  end

  def reset_login_limit
    user_key = "#{self.id}:#{Time.now.hour}"
    REDIS_CACHE.set user_key, 0
  end

  def within_limits?
    user_key = "#{self.id}:#{Time.now.hour}"
    request_count = REDIS_CACHE.incrby user_key, 1
    REDIS_CACHE.expire user_key, 3600
    request_count < RATE_LIMIT
  end

  def self.ms_chap_auth params
    auth_failed_message =  "NT_STATUS_UNSUCCESSFUL: Failure (0xC0000001)"

    addresses = params[:addresses]
    user_name = params[:user]
    challenge_string = params[:challenge]
    response_string = params[:response]

    return auth_failed_message  if user_name.blank? || challenge_string.blank? || response_string.blank? || addresses.blank?

    address_array = addresses.split

    user = User.get_user user_name
    if user.present? && user.permitted_vpns?(address_array)
      drift_interval = 30
      t = Time.now
      otps = []
      otps.push(user.get_user_otp_at(t))
      otps.push(user.get_user_otp_at(t - drift_interval))
      otps.push(user.get_user_otp_at(t + drift_interval))
      return user.authenticate_ms_chap_with_drift otps, challenge_string, response_string
    else
      return auth_failed_message
    end
  end

  #this method is here because we need to mock/stub for testing
  def get_user_otp
    return ROTP::TOTP.new(self.auth_key).now
  end

  def get_user_otp_at time
    return ROTP::TOTP.new(self.auth_key).at time
  end

  def user_passwd_response
    user_hash = {}
    user_hash[:pw_name] = user_login_id
    user_hash[:pw_passwd] = 'x'
    user_hash[:pw_uid] = uid.to_i

    # If gid is supplied (avoid N+1)
    if respond_to?(:gid) && gid
      user_hash[:pw_gid] = gid.to_i
    elsif respond_to?(:gid_count)
      if gid_count.positive?
        user_hash[:pw_gid] = groups.where(name: user_login_id).first.gid
      end
    elsif groups.where(name: user_login_id).count.positive?
      user_hash[:pw_gid] = groups.where(name: user_login_id).first.gid
    end

    user_hash[:pw_gecos] = name.to_s
    user_hash[:pw_dir] = "#{HOME_DIR}/#{user_login_id}"
    user_hash[:pw_shell] = '/bin/bash'
    user_hash
  end

  def group_admin?
    GroupAdmin.find_by_user_id(self.id).present?
  end

  private

  def remove_default_admin
    admin_users = User.where('active = ? and admin = ? and id <> ?', true, true, id)
    if (!admin || !active) && admin_users.blank?
      errors.add(:admin, 'You cannot remove or make inactive the default admin account')
    end
  end

  def validate_email_domain
    domain_list = ENV['GATE_HOSTED_DOMAINS'].split(',')
    domain = email.split('@').last
    errors.add(:email, "Invalid Domain for Email Address") unless domain_list.include?(domain)
  end

  def revoke_admin_when_inactive
    self.admin = false unless active
  end

  def set_deactivated_at_when_inactive
    unless active
      self.deactivated_at = Time.current
    end
  end
end
