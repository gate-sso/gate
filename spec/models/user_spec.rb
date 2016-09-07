require 'rails_helper'
UID_CONSTANT = 5000

RSpec.describe User, type: :model do

  before(:each) do
    group = create(:group)
  end

  it "should check uid creation with offset" do
    user = create(:user)
    expect(user.uid.to_i).to eq(user.id + UID_CONSTANT)

  end

  it "should return false if user is not active" do
    user = create(:user)
    response =  User.get_shadow_name_response user.name
    expect(response[:sp_namp]).to eq("test4")
  end
  it "should return false if user is not active" do
    group = create(:group)
    user = create(:user)
    response =  User.get_passwd_uid_response user.uid
    expect(response[:pw_name]).to eq("test5")
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
    expect(user.get_user_unix_name).to eq("janata_naam")
  end

  it "should return false if user is not permitted" do
    user = create(:user)
    response = user.permitted_hosts? ["10.1.1.1."]

    expect(response).to eq (false)
  end
end
