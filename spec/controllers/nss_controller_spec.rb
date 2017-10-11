require 'rails_helper'

RSpec.describe NssController, type: :controller do
  let(:access_token) { SecureRandom.uuid }
  let(:email) { Faker::Internet.email }

  before(:each) do
    group = create(:group)
  end

  it "should return false for invalid token" do
    get :groups_list, token: access_token, email: email
    data = JSON.parse(response.body)
    expect(data["success"]).to eq(false)
  end

  it "should return false for not registered email" do
    create(:access_token, token: access_token)
    get :groups_list, token: access_token, email: email
    data = JSON.parse(response.body)
    expect(data["success"]).to eq(false)
  end

  it "should return group list for registered email" do
    create(:access_token, token: access_token)
    create(:user, email: email)
    get :groups_list, token: access_token, email: email
    data = JSON.parse(response.body)
    expect(data["success"]).to eq(true)
  end

  it "should remove user from group" do
    create(:access_token, token: access_token)
    user = create(:user, email: email)
    old_group_size = user.groups.size
    delete :remove_user_from_group, token: access_token, name: user.email, group_name: user.groups.last.name
    data = JSON.parse(response.body)
    expect(data["success"]).to eq(true)
    expect(user.groups.size).not_to eq(old_group_size - 1)
  end
end
