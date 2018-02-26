require 'rails_helper'

RSpec.describe NssController, type: :controller do
  let(:access_token) { SecureRandom.uuid }
  let(:email) { Faker::Internet.email }
  let(:user) { FactoryBot.create(:user, name: "foobar", user_login_id: "foobar", email: "foobar@foobar.com")  }

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

  it "should return sysadmins for that host" do 

    sign_in user
    access_token = create(:access_token)

    json =  { token: access_token.token, name: "random_host_01" }
    post "add_host", { token: access_token.token, name: "random_host_01", format: :json}
    body = response.body
    access_key = JSON.parse(body)["access_key"]

    host = HostMachine.find_by(name: "random_host_01")
    expect(access_key).to eq host.access_key


    group = create(:group)
    user = create(:user)
    group.host_machines << host
    if !group.member? user
      group.users << user
    end
    user = create(:user)
    if !group.member? user
      group.users << user
    end
    group.save!
    host.reload
    group.reload

    expect(host.sysadmins.count).to eq 2
    get "host", { token: access_key, format: json }
    body = JSON.parse(response.body)

    expect(body.count).to eq 3
    expect(body[2]["gr_mem"].count).to eq 2


    get "group", { token: access_key, format: json }
    body = JSON.parse(response.body)

    expect(body.count).to eq 3
    expect(body[2]["gr_mem"].count).to eq 2

  end

end
