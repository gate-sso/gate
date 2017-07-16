class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  #devise :database_authenticatable, :registerable,
  #  :recoverable, :rememberable, :trackable, :validatable, :omniauthable
  devise :timeoutable, :omniauthable, :omniauth_providers => [:google_oauth2]
  has_many :hosts
  has_many :group_associations
  has_many :groups, through: :group_associations

  #we should put this in configuration
  ##TODO move this to environemnt variable or configuration
  # 
  after_create :add_uid
  UID_CONSTANT = 5000
  HOME_DIR = "/home"
  USER_SHELL = "/bin/bash"


  def add_uid
    self.uid = id + UID_CONSTANT
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
    group = Group.create(name: user.get_user_unix_name)
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
      group = Group.create(name: user.get_user_unix_name)
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
        return true if /^#{host.host_pattern}/.match(host_name).present?
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

  def self.get_user email
    splitted_email = email.split '@'
    user = nil
    if splitted_email.count > 1
      user = User.where(email: email).first 
    else
      user = User.where(email: "#{email}@#{ENV['GATE_EMAIL_DOMAIN']}").first 
      if user.blank?
        email = email.gsub(/_/, '.')
        user = User.where(email: "#{email}@#{ENV['GATE_EMAIL_DOMAIN']}").first 
      end
    end
    return nil if user.present? and user.active == false
    return user
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

  def get_user_unix_name
    email.split('@').first
    #email.split('@').first.gsub(/\./,'_')
  end

  def self.get_shadow_name_response name
    user = User.where(name: name).first
    return nil if user.blank?

    user.get_shadow_hash
  end

  def get_shadow_hash
    shadow_hash = {}
    shadow_hash[:sp_namp] = get_user_unix_name
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

  def user_passwd_response 
    user_hash = {}
    user_hash[:pw_name] = get_user_unix_name
    user_hash[:pw_passwd]  = "x"
    user_hash[:pw_uid] = uid.to_i
    user_hash[:pw_gid] = groups.where(name: get_user_unix_name).first.gid
    user_hash[:pw_gecos]  = "#{name}"
    user_hash[:pw_dir] = "#{HOME_DIR}/#{get_user_unix_name}"
    user_hash[:pw_shell] = "/bin/bash"
    user_hash
  end

  def self.find_by_email(email)
    User.where(email: email, active: true).first
  end

  def group_names_list
    self.groups.map(&:name)
  end
end
