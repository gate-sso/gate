require 'rails_helper'
UID_CONSTANT = 5000

RSpec.describe User, type: :model do

  before(:each) do
    group = create(:group)
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
    expect(response[:sp_namp]).to eq(user.get_user_unix_name)
  end

  it "should return false if user is not active" do
    user = create(:user)
    response =  User.get_passwd_uid_response user.uid
    expect(response[:pw_name]).to eq(user.get_user_unix_name)
  end

  it "should get all users for passwd" do
    user = create(:user)
    user = create(:user)

    response = User.get_all_passwd_response
    expect(response.count).to eq(2)
  end

  it "should return _ for . in name" do
    user = create(:user)
    user.email = "janata.naam@test.com"
    expect(user.get_user_unix_name).to eq("janata.naam")
    user.save!
    ENV['GATE_EMAIL_DOMAIN'] = "test.com"
    user = User.get_user("janata_naam")
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
    user = User.find_by_email(email)
    expect(user.email).to eq(email)
  end

  it 'should return nil if email not registered' do
    email = Faker::Internet.email
    user = User.find_by_email(email)
    expect(user.blank?).to eq(true)
  end

  it 'should return registered groups list' do
    email = Faker::Internet.email
    create(:user, email: email)
    user = User.find_by_email(email)
    expect(user.group_names_list.include?(user.get_user_unix_name)).to eq(true)
  end

  it "should check valid hosted domain" do
    ENV["GATE_HOSTED_DOMAINS"] = "alfa.com,beta.com"
    expect(User.valid_domain? "alfa.com").to be true
    expect(User.valid_domain? "beta.com").to be true
    expect(User.valid_domain? "gama.com").to be false

    ENV["GATE_HOSTED_DOMAINS"] = ""
    expect(User.valid_domain? "alfa.com").to be false
  end
end
