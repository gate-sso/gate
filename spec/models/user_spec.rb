require 'rails_helper'

RSpec.describe User, type: :model do
  let(:uid_constant) { 5000 }
  describe 'generate_login_id' do
    it 'should generate login id' do
      user = build(:user)
      expect(user.generate_login_id).to eq(user.email.split('@').first)
    end
  end

  describe 'find_and_validate_saml_user' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }
    it 'returns false if user is not active' do
      user.update_attribute(:active, false)
      expect(User.find_and_validate_saml_user(user.email, 123456, 'datadog')).to eq(false)
    end

    it 'returns false if the user doesn\'t belong to app group' do
      expect(User.find_and_validate_saml_user(user.email, 123456, 'datadog')).to eq(false)
    end

    it 'returns user if all credentials are valid' do
      user.groups << group
      allow_any_instance_of(User).to receive(:valid_otp?).and_return(true)
      expect(User.find_and_validate_saml_user(user.email, 123456, group.name)).to eq(user)
    end

    it 'validates the user password' do
      user.groups << group
      expect_any_instance_of(User).to receive(:valid_otp?)
      User.find_and_validate_saml_user(user.email, 123456, group.name)
    end
  end

  describe 'valid_otp?' do
    let(:user) { create(:user) }
    before do
      user.generate_two_factor_auth(true)
      Timecop.freeze
    end

    it 'expires redis cache' do
      user_key = "#{user.id}:#{Time.now.hour}"
      expect(REDIS_CACHE).to receive(:expire).with(user_key, 3600)
      user.valid_otp?(123456)
    end

    it 'return false if rate limit is exceeded' do
      user_key = "#{user.id}:#{Time.now.hour}"
      allow(REDIS_CACHE).to receive(:incrby).with(user_key, 1).and_return(RATE_LIMIT + 1)
      expect(user.valid_otp?(123456)).to eq(false)
    end

    it 'validates otp token' do
      allow_any_instance_of(ROTP::TOTP).to receive(:now).and_return(123456)
      expect(user.valid_otp?(123456)).to eq(true)
    end
  end

  describe 'generate_uid' do
    let(:user) { build(:user) }
    it 'should generate uid' do
      expect(user.generate_uid).to eq(uid_constant)
    end

    it 'should generate uid as the uid buffer if there are no records' do
      user_new = create(:user)
      expect(user_new.generate_uid).to eq(User.last.id + uid_constant)
    end

    it 'should use configured uid buffer rather than the default value' do
      cached_uid_buffer = ENV['UID_BUFFER']
      ENV['UID_BUFFER'] = '6000'
      expect(user.generate_uid).to eq(6000)
      ENV['UID_BUFFER'] = cached_uid_buffer
    end
  end

  describe 'initialize_host_and_group' do
    let(:user) { build(:user) }
    it 'should initialize host for the user' do
      user.initialise_host_and_group
      expect(user.hosts.size).to eq(1)
    end

    it 'should initialize group for the user' do
      user.initialise_host_and_group
      expect(user.groups.size).to eq(1)
    end

    it 'should set the host pattern if configured' do
      cached_default_host_pattern = ENV['DEFAULT_HOST_PATTERN']
      ENV['DEFAULT_HOST_PATTERN'] = 'S*'
      user.initialise_host_and_group
      expect(user.hosts.first.host_pattern).to eq('S*')
      ENV['DEFAULT_HOST_PATTERN'] = cached_default_host_pattern
    end
  end

  describe 'create_user' do
    it 'shouldn\'t create the user if email is already registered' do
      user = create(:user)
      User.create_user(user.name, user.email)
      expect(User.where(email: user.email).size).to eq(1)
    end

    it 'should create admin user if its first user being created' do
      user_data = attributes_for(:user)
      user = User.create_user(user_data[:name], user_data[:email])
      expect(user.admin).to eq(true)
    end

    it 'should generate login id' do
      user_data = attributes_for(:user)
      expect_any_instance_of(User).to receive(:generate_login_id)
      User.create_user(user_data[:name], user_data[:email])
    end

    it 'should generate uid' do
      user_data = attributes_for(:user)
      expect_any_instance_of(User).to receive(:generate_uid)
      User.create_user(user_data[:name], user_data[:email])
    end

    it 'should initialise host and group for user' do
      user_data = attributes_for(:user)
      expect_any_instance_of(User).to receive(:initialise_host_and_group)
      User.create_user(user_data[:name], user_data[:email])
    end
  end

  describe 'generate_two_factor_auth' do
    let(:rotp_key) { ROTP::Base32.random_base32 }
    let(:new_rotp_key) { ROTP::Base32.random_base32 }

    before(:each) do |ex|
      unless ex.metadata[:skip_before]
        allow(ROTP::Base32).to receive(:random_base32).and_return(rotp_key)
      end
    end

    it 'shouldn\'t generate key if user is not created' do
      user = build(:user)
      user.generate_two_factor_auth
      expect(user.auth_key.blank?).to eq(true)
      expect(user.provisioning_uri.blank?).to eq(true)
    end

    it 'should generate auth_key' do
      user = create(:user)
      user.generate_two_factor_auth
      expect(user.auth_key).to eq(rotp_key)
    end

    it 'should update provisioning url' do
      user = create(:user)
      user.generate_two_factor_auth
      url = ROTP::TOTP.new(rotp_key).provisioning_uri "GoJek-C #{user.email}"
      expect(user.provisioning_uri).to eq(url)
    end

    it 'shouldn\'t generate the token if it\'s already generated', skip_before: true do
      user = create(:user)
      allow(ROTP::Base32).to receive(:random_base32).and_return(new_rotp_key)
      url = ROTP::TOTP.new(new_rotp_key).provisioning_uri "GoJek-C #{user.email}"
      user.generate_two_factor_auth
      allow(ROTP::Base32).to receive(:random_base32).and_return(rotp_key)
      user.generate_two_factor_auth
      user.reload
      expect(user.auth_key).to eq(new_rotp_key)
      expect(user.provisioning_uri).to eq(url)
    end

    it 'should generate the token if its already generated and force_generate is true',
      skip_before: true do
      user = create(:user)
      allow(ROTP::Base32).to receive(:random_base32).and_return(new_rotp_key)
      url = ROTP::TOTP.new(new_rotp_key).provisioning_uri "GoJek-C #{user.email}"
      user.generate_two_factor_auth true
      allow(ROTP::Base32).to receive(:random_base32).and_return(rotp_key)
      user.generate_two_factor_auth
      expect(user.auth_key).to eq(rotp_key)
      expect(user.provisioning_uri).to eq(url)
    end
  end

  describe 'add_temp_user' do
    let(:user_data) { attributes_for(:user) }
    let(:rotp_key) { ROTP::Base32.random_base32 }
    let(:domain) { 'test.com' }
    before(:each) do
      @cached_gate_hosted_domain = ENV['GATE_HOSTED_DOMAIN']
      ENV['GATE_HOSTED_DOMAIN'] = domain
      allow(ROTP::Base32).to receive(:random_base32).and_return(rotp_key)
    end

    after(:each) do
      ENV['GATE_HOSTED_DOMAIN'] = @cached_gate_hosted_domain
    end

    it 'the email should be appended with the configured hosted domain' do
      User.add_temp_user(user_data[:name], user_data[:email])
      user = User.where(email: "#{user_data[:email]}@#{domain}").first
      expect(user.present?).to eq(true)
    end

    it 'should generate auth_key' do
      expect_any_instance_of(User).to receive(:generate_two_factor_auth)
      User.add_temp_user(user_data[:name], user_data[:email])
    end
  end

  describe 'update_profile' do
    let(:user) { create(:user) }
    it 'should update user profile' do
      public_key = OpenSSL::PKey::RSA.new(2048).public_key.to_pem
      attrs = { name: Faker::Name.name, admin: true, active: true, public_key: public_key }
      user.update_profile(attrs)
      expect(user.name).to eq(attrs[:name])
      expect(user.admin).to eq(attrs[:admin])
      expect(user.active).to eq(attrs[:active])
      expect(user.public_key).to eq(attrs[:public_key])
    end

    it 'should update the product name' do
      name = 'test_product'

      user.update_profile(product_name: name)

      expect(user.product_name).to eq(name)
    end

    it 'should update the name' do
      name = 'test_name'

      user.update_profile(name: name)

      expect(user.name).to eq(name)
    end

    it 'should update the public_key' do
      rsa_key = OpenSSL::PKey::RSA.new(2048)
      public_key = rsa_key.public_key.to_pem

      user.update_profile(public_key: public_key)

      expect(user.public_key).to eq(public_key)
    end

    it 'should update user profile only for public_key, name, product_name, admin and active' do
      auth_key = ROTP::Base32.random_base32
      user.update_profile(auth_key: auth_key)
      expect(user.auth_key).not_to eq(auth_key)
    end

    it 'should update the deactivated_at date if user is made inactive' do
      Timecop.freeze(Time.current)
      inactive_user = create(:user, admin: true)
      inactive_user.update_profile(active: false)
      expect(inactive_user.deactivated_at.to_s).to eq(Time.current.to_s)
    end

    it 'shouldn\'t make the admin user a normal user if its only single admin user' do
      user.update_profile(active: false)
      expect(user.errors.messages.key?(:admin)).to eq(true)
      expect(user.valid?).to eq(false)
    end
  end

  describe '#update' do
    context 'deactivate admin user' do
      it 'should revoke admin status' do
        create(:admin_user)
        admin = create(:admin_user)

        admin.update(active: false)
        admin.reload

        expect(admin.admin?).to be false
      end
    end
  end

  describe '#group_expiration_date' do
    it 'should return expiration date from group' do
      user = create(:user)
      group = create(:group)
      expiration_date = Date.parse('2019-10-20')
      group.add_user_with_expiration(user.id, expiration_date)

      user_expiration_date = user.group_expiration_date group.id

      expect(user_expiration_date).to eq(expiration_date)
    end
  end
end

UID_CONSTANT = 5000
RSpec.describe User, type: :model do

  before(:each) do
    create(:group)
  end

  it "should set deactivation time when user is deactivated" do
    user = create(:user)
    user.update_profile(active: false)
    expect(user.deactivated_at).not_to be nil
  end

  describe ".purge!" do
    it "should remove group associations for inactive user" do
      create(:user)
      user = create(:user)
      user.update!(active: false)
      user.purge!
      user.reload
      expect(user.group_associations.length).to eq 0
    end

    it "should NOT remove group associations for active user" do
      user = create(:user)
      user.purge!
      user.reload
      expect(user.group_associations.length).not_to eq 0
    end
  end

  it "should check valid email address" do
    #email address always has 2 parts
    email_address = "satrya@gmail.com"
    expect(User.check_email_address(email_address)).to eq(true)

    email_address = "satraya @gmail.com"
    expect(User.check_email_address(email_address)).to eq(false)

    email_address = "satraya@-gmail.com"
    expect(User.check_email_address(email_address)).to eq(false)

    email_address = "sat*raya@gmail.com"
    expect(User.check_email_address(email_address)).to eq(false)
  end

  it "should check uid creation with offset" do
    user = create(:user)
    expect(user.uid.to_i).to eq(user.id + UID_CONSTANT)
  end

  it "should return false if user is not active" do
    user = create(:user)
    response = User.get_shadow_name_response user.name
    expect(response[:sp_namp]).to eq(user.user_login_id)
  end

  it "should return false if user is not active" do
    user = create(:user)
    response = User.get_passwd_uid_response user
    expect(response[:pw_name]).to eq(user.user_login_id)
  end

  it "should get all users for passwd" do
    user = create(:user)
    user = create(:user)

    response = User.get_all_passwd_response
    expect(response.count).to eq(2)
  end

  it "should return _ for . in name" do
    user = create(:user)
    expect(user.user_login_id).to eq(user.email.split("@").first)
    user = User.get_user(user.user_login_id)
    expect(user).not_to be nil
  end

  it "should return false if user is not permitted" do
    user = create(:user)
    response = user.permitted_hosts? ["10.1.1.1."]

    expect(response).to eq (false)
  end

  it 'should return user if email registered' do
    email = Faker::Internet.email
    create(:user, email: email)
    user = User.find_active_user_by_email(email)
    expect(user.email).to eq(email)
  end

  it 'should return nil if email not registered' do
    email = Faker::Internet.email
    user = User.find_active_user_by_email(email)
    expect(user.blank?).to eq(true)
  end

  it 'should return registered groups list' do
    email = Faker::Internet.email
    create(:user, email: email)
    user = User.find_active_user_by_email(email)
    expect(user.group_names_list.include?(user.user_login_id)).to eq(true)
  end

  it 'should check valid hosted domain' do
    allow(ENV).to receive(:[]).with('GATE_HOSTED_DOMAINS').and_return('alfa.com,beta.com')
    expect(User.valid_domain?('alfa.com')).to be true
    expect(User.valid_domain?('beta.com')).to be true
    expect(User.valid_domain?('gama.com')).to be false

    allow(ENV).to receive(:[]).with('GATE_HOSTED_DOMAINS').and_return('')
    expect(User.valid_domain?('alfa.com')).to be false
  end

  it "should fails host address if it's not permitted" do
    user = create(:user)
    host = Host.new
    host.user = user
    host.host_pattern = "s*" #by default give host access to all staging instances
    host.save!
    expect(user.permitted_hosts?(["10.0.0.0"])).to be false
  end

  it "should pass host address if it's permitted" do
    user = create(:user)
    host = Host.new
    host.user = user
    host.host_pattern = ".*" #by default give host access to all staging instances
    host.save!
    expect(user.permitted_hosts?(["10.0.0.0"])).to be true
  end

  it "login limits should pass" do
    user = create(:user)
    user.reset_login_limit
    (RATE_LIMIT - 2).times do
      user.within_limits?
    end
    expect(user.within_limits?).to be true
  end

  it "login limits should fail" do
    user = create(:user)
    (RATE_LIMIT + 2).times do
      user.within_limits?
    end
    expect(user.within_limits?).to be false
  end

  it "should authenticate ms chap" do
    user = create(:user)
    totp = "757364"
    challenge_string = "ee85e142eadfec52"
    response_string = "0392a9e43edee3129f735b37fd9d0b0d3f66aa7a00f35440"

    expect(user.authenticate_ms_chap(totp, challenge_string, response_string)).to eq("NT_KEY: 57247E8BAD1959F9544B2C5057F77AD8")
    expect(user.authenticate_ms_chap("78787", challenge_string, response_string)).to eq("NT_STATUS_UNSUCCESSFUL: Failure (0xC0000001)")
  end

  it "should authenticate ms chap with drift" do
    user = create(:user)
    challenge_string = "ee85e142eadfec52"
    response_string = "0392a9e43edee3129f735b37fd9d0b0d3f66aa7a00f35440"

    totp = ["757364", "123456", "876543"]
    expect(user.authenticate_ms_chap_with_drift(totp, challenge_string, response_string)).to eq("NT_KEY: 57247E8BAD1959F9544B2C5057F77AD8")

    totp = ["123456", "757364", "876543"]
    expect(user.authenticate_ms_chap_with_drift(totp, challenge_string, response_string)).to eq("NT_KEY: 57247E8BAD1959F9544B2C5057F77AD8")

    totp = ["123456", "876543", "757364"]
    expect(user.authenticate_ms_chap_with_drift(totp, challenge_string, response_string)).to eq("NT_KEY: 57247E8BAD1959F9544B2C5057F77AD8")

    expect(user.authenticate_ms_chap_with_drift(["78787", "121212", "545454"], challenge_string, response_string)).to eq("NT_STATUS_UNSUCCESSFUL: Failure (0xC0000001)")
  end

  it "should authenticate ms chap" do
    user = create(:user)
    vpn = Vpn.create(name: :"X", ip_address: "10.240.0.1" )
    user.groups.first.vpns << vpn
    params = {}
    params[:addresses] = "10.240.0.1"
    params[:user] = user.user_login_id
    params[:challenge] = "ee85e142eadfec52"
    params[:response] = "0392a9e43edee3129f735b37fd9d0b0d3f66aa7a00f35440"

    allow_any_instance_of(User).to receive(:get_user_otp_at).and_return("757364")

    expect(User.ms_chap_auth(params)).to eq("NT_KEY: 57247E8BAD1959F9544B2C5057F77AD8")
  end

  it "should return different otps for different times" do
    user = create(:user)
    user.auth_key = ROTP::Base32.random_base32

    drift_interval = 30
    t = Time.now
    otp1 = user.get_user_otp_at(t)
    otp2 = user.get_user_otp_at(t - drift_interval)
    otp3 = user.get_user_otp_at(t + drift_interval)

    expect(otp1).to_not equal(otp2)
    expect(otp2).to_not equal(otp3)
    expect(otp3).to_not equal(otp1)
  end

  describe '.get_user_pass_attributes' do
    it 'should return token and email if token and email is passed' do
      params = { email: Faker::Internet.email, token: SecureRandom.uuid, user: '', password: '' }
      expect(User.get_user_pass_attributes(params)).to eq([params[:email], params[:token]])
    end

    it 'should return password and email if email and password is present, and token is not present' do
      params = { email: Faker::Internet.email, token: '', user: '', password: SecureRandom.uuid }
      expect(User.get_user_pass_attributes(params)).to eq([params[:email], params[:password]])
    end

    it 'should return user and token if user and token is present, and email is not present' do
      params = { email: '', token: SecureRandom.uuid, user: Faker::Internet.email, password: '' }
      expect(User.get_user_pass_attributes(params)).to eq([params[:user], params[:token]])
    end

    it 'should return user and password if user and password is present and email and token is not present' do
      params = { email: '', token: '', user: Faker::Internet.email, password: SecureRandom.uuid }
      expect(User.get_user_pass_attributes(params)).to eq([params[:user], params[:password]])
    end

    it 'should return nil and nil if email and user is blank or password and token is blank' do
      params = { email: '', token: '', user: '', password: '' }
      expect(User.get_user_pass_attributes(params)).to eq([nil, nil])
    end
  end

  describe '.get_user' do
    after(:each) do
      User.destroy_all
    end

    context 'when two users exist with same login_id' do
      let(:user_login_id) {'same-id'}
      subject(:user) {User.get_user(user_login_id)}

      let(:first_user) {build(:user, user_login_id: user_login_id, name: 'Test1', email: "#{user_login_id}@test.com")}
      let(:second_user) {build(:user, user_login_id: user_login_id, name: 'Test2', email: "#{user_login_id}@aux.test.com")}

      it 'returns first found active user' do
        first_user.save
        second_user.save

        expect(user.name).to eq(first_user.name)
      end

      it 'returns only active user' do
        first_user.active = false
        second_user.active = false
        first_user.save
        second_user.save

        expect(user).to be_nil
      end
    end
  end

  describe '.add_user' do

    it 'creates a new user' do
      user_data = build(:user)
      domain = user_data.email.split('@').last
      user = User.add_user(user_data.first_name, user_data.last_name, user_data.user_role, domain)
      expect(user.persisted?).to eq(true)
    end

    it 'creates a user with email in format first_name.last_name' do
      user_data = build(:user)
      domain = user_data.email.split('@').last
      user = User.add_user(user_data.first_name, user_data.last_name, user_data.user_role, domain)
      expect(user.persisted?).to eq(true)
      expect(user.email).to eq("#{user.first_name.downcase}.#{user.last_name.downcase}@#{domain}")
    end

    it 'generate uid' do
      user_data = build(:user)
      domain = user_data.email.split('@').last
      expect_any_instance_of(User).to receive(:generate_uid)
      User.add_user(user_data.first_name, user_data.last_name, user_data.user_role, domain)
    end

    it 'generates login id' do
      user_data = build(:user)
      domain = user_data.email.split('@').last
      user = User.add_user(user_data.first_name, user_data.last_name, user_data.user_role, domain)
      expect(user.user_login_id).to eq("#{user_data.first_name.downcase}.#{user_data.last_name.downcase}")
    end

    it 'initializes host groups' do
      user_data = build(:user)
      domain = user_data.email.split('@').last
      expect_any_instance_of(User).to receive(:initialise_host_and_group)
      User.add_user(user_data.first_name, user_data.last_name, user_data.user_role, domain)
    end

    xit 'fails if required fields are not present' do
      user_data = build(:user)
      domain = user_data.email.split('@').last
      user = User.add_user('', user_data.last_name, user_data.user_role, domain)
      expect(user.persisted?).to eq(false)
    end

    xit 'fails if domain doesn\'t exist in list of domains' do
      user_data = build(:user)
      user = User.add_user(user_data.first_name, user_data.last_name, user_data.user_role, Faker::Internet.domain_name)
      expect(user.persisted?).to eq(false)
    end

    it 'fails if email is already taken' do
      user_data = build(:user)
      domain = user_data.email.split('@').last
      user_data.save
      user = User.add_user(user_data.first_name, user_data.last_name, user_data.user_role, domain)
      expect(user.persisted?).to eq(false)
    end
  end
end
