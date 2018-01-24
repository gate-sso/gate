class User < ActiveRecord::Base
  has_paper_trail

  include MsChapAuth
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #  :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  devise :timeoutable, :omniauthable, :omniauth_providers => [:google_oauth2]
  has_many :hosts

  has_many :group_associations
  has_many :groups, through: :group_associations

  has_many :vpn_group_user_associations
  has_many :vpns, through: :vpn_group_user_associations

  has_many :group_admin, dependent: :destroy
  belongs_to :vpn

  has_one :access_token

  #we should put this in configuration
  ##TODO move this to environemnt variable or configuration
  #
  after_create :add_system_attributes
  UID_CONSTANT = 5000
  HOME_DIR = "/home"
  USER_SHELL = "/bin/bash"


  def self.by_token(token)
    User.joins(:access_token).where("access_tokens.token = ? and users.active = ?", token, true).first
  end

  def update_profile(attrs)
    self.public_key = attrs['public_key'].blank? ? self.public_key : attrs['public_key']
    self.name = attrs['name'].blank? ? self.name : attrs['name']
    self.product_name = attrs['product_name'].blank? ? self.product_name : attrs['product_name']
    self.save!
  end

  def add_system_attributes
    self.uid = id + UID_CONSTANT
    self.user_login_id = self.email.split("@").first
    self.save!
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

  def self.add_temp_user (name, email)
    email = email + "@" + ENV['GATE_HOSTED_DOMAIN'].to_s
    user = User.create(name:name, email: email)
    host = Host.new
    host.user = user
    host.host_pattern = "s*" #by default give host access to all staging instances
    host.save!


    #Add user to default user's group
    group = Group.create(name: user.user_login_id)
    user.groups << group
    user.save!

    if user.persisted? and user.auth_key.blank?
      user.auth_key = ROTP::Base32.random_base32
      totp = ROTP::TOTP.new(user.auth_key)
      user.provisioning_uri = totp.provisioning_uri "GoJek-C #{name}"
      user.save!
    end
    user.auth_key
  end

  def self.valid_domain? domain
    hosted_domains = ENV['GATE_HOSTED_DOMAINS'].split(",")
    hosted_domains.include?(domain)
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(:email => data["email"]).first

    # Uncomment the section below if you want users to be created if they don't exist
    unless user
      user = User.create(name: data["name"],
                         email: data["email"]
                        )
      host = Host.new
      host.user = user
      host.host_pattern = "s*" #by default give host access to all staging instances
      host.save!


      #Add user to default user's group
      group = Group.create(name: user.user_login_id)
      user.groups << group
      user.save!
    end
    user
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
      vpns.each do |vpn|
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
    token = params[:token]
    email = params[:email]
    email = params[:user] if email.blank?
    token = params[:password] if token.blank?

    return [null, null] if email.blank? || token.blank?
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


  def self.get_passwd_uid_response uid
    user = User.where(uid: uid).first
    return [] if user.blank?
    user.user_passwd_response
  end

  def self.find_active_user_by_email(email)
    User.where(email: email, active: true).first
  end

  def group_names_list
    self.groups.map(&:name)
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
    if user.permitted_hosts?(address_array) || user.permitted_vpns?(address_array)
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
    user_hash[:pw_passwd]  = "x"
    user_hash[:pw_uid] = uid.to_i
    user_hash[:pw_gid] = groups.where(name: user_login_id).first.gid if groups.where(name: user_login_id).count > 0
    user_hash[:pw_gecos]  = "#{name}"
    user_hash[:pw_dir] = "#{HOME_DIR}/#{user_login_id}"
      user_hash[:pw_shell] = "/bin/bash"
    user_hash
  end

  def group_admin?
    GroupAdmin.find_by_user_id(self.id).present?
  end
end
