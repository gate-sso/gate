require 'rails_helper'
UID_CONSTANT = 5000

RSpec.describe User, type: :model do

  before(:each) do
    create(:group)
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
    response =  User.get_shadow_name_response user.name
    expect(response[:sp_namp]).to eq(user.user_login_id)
  end

  it "should return false if user is not active" do
    user = create(:user)
    response =  User.get_passwd_uid_response user.uid
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
    ENV['GATE_EMAIL_DOMAIN'] = "test.com"
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

  it "should check valid hosted domain" do
    ENV["GATE_HOSTED_DOMAINS"] = "alfa.com,beta.com"
    expect(User.valid_domain? "alfa.com").to be true
    expect(User.valid_domain? "beta.com").to be true
    expect(User.valid_domain? "gama.com").to be false

    ENV["GATE_HOSTED_DOMAINS"] = ""
    expect(User.valid_domain? "alfa.com").to be false
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

  it "should check user login limits" do
    user = create(:user)
    (RATE_LIMIT - 2).times do
      user.within_limits?
    end
    expect(user.within_limits?).to be true
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
  it "should authenticate ms chap" do
    user = create(:user)
    host = Host.new
    host.user = user
    host.host_pattern = ".*"
    host.save!
    params = {}
    params[:addresses] = "10.240.0.1"
    params[:user] = user.user_login_id
    params[:challenge] = "ee85e142eadfec52"
    params[:response] = "0392a9e43edee3129f735b37fd9d0b0d3f66aa7a00f35440"

    allow_any_instance_of(User).to receive(:get_user_otp_at).and_return("757364")

    expect(User.ms_chap_auth(params)).to eq("NT_KEY: 57247E8BAD1959F9544B2C5057F77AD8")
  end

  describe '.get_user' do
    after(:each) do
      User.destroy_all
    end

    context 'when two users exist with same login_id' do
      let(:user_login_id) { 'same-id' }
      subject(:user) { User.get_user(user_login_id) }

      let(:first_user) { build(:user, user_login_id: user_login_id, name: 'Test1', email: "#{user_login_id}@test.com") }
      let(:second_user) { build(:user, user_login_id: user_login_id, name: 'Test2', email: "#{user_login_id}@aux.test.com") }

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
end
