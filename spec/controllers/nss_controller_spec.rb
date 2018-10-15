require 'rails_helper'

RSpec.describe NssController, type: :controller do
  let(:access_token) { SecureRandom.uuid }
  let(:email) { Faker::Internet.email }
  let(:user) { FactoryBot.create(:user, name: "foobar", user_login_id: "foobar", email: "foobar@foobar.com")  }

  before(:each) do
    group = create(:group)
  end

  it "should return false for invalid token" do
    get :groups_list, params: { token: access_token, email: email }
    data = JSON.parse(response.body)
    expect(data["success"]).to eq(false)
  end

  it "should return false for not registered email" do
    create(:access_token, token: access_token)
    get :groups_list, params: { token: access_token, email: email }
    data = JSON.parse(response.body)
    expect(data["success"]).to eq(false)
  end

  it "should return group list for registered email" do
    create(:access_token, token: access_token)
    user_test = create(:user, email: email)
    get :groups_list, params: { token: access_token, email: email }
    data = JSON.parse(response.body)
    expect(data["success"]).to eq(true)
  end

  it 'should not return sysadmins for invalid token' do
    json = { token: '', name: 'random_host', group_name: '', format: :json }
    post 'add_host', params: json
    body = response.body
    expect(JSON.parse(body)['success']).to eq(false)
  end

  it "should not create groups and admins again for the same host name" do

    create(:access_token, token: access_token)
    json = { token: access_token, name: 'random_host', group_name: 'duplicate_group', format: :json }
    post 'add_host', params: json
    body = response.body
    expect(JSON.parse(body)['success']).to eq(true)
    expect(JSON.parse(body)['groups'].count).to eq 2

    json = { token: access_token, name: 'random_host', group_name: 'duplicate_group', format: :json }
    post 'add_host', params: json
    body = response.body
    expect(JSON.parse(body)['success']).to eq(true)
    expect(JSON.parse(body)['groups'].count).to eq 2
  end

  it "should return sysadmins for that host" do
    sign_in user
    access_token = create(:access_token)
    json =  { token: access_token.token, name: "random_host_01" }
    post "add_host", params: { token: access_token.token, name: "random_host_01", group_name: "random_group_01", format: :json}
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
    get "host", params: { token: access_key, format: json }
    body = JSON.parse(response.body)

    expect(body.count).to eq 3
    expect(body[2]["gr_mem"].count).to eq 2


    get "group", params: { token: access_key, format: json }
    body = JSON.parse(response.body)

    expect(body.count).to eq 3
    expect(body[0]["gr_mem"].count).to eq 1
    expect(body[1]["gr_mem"].count).to eq 1
    expect(body[2]["gr_mem"].count).to eq 2

    expect(Group.find_by(name: "random_group_01")).not_to eq nil
    expect(Group.find_by(name: "random_host_01_host_group")).not_to eq nil

  end

  it "should return members of sysadmins if no other group exists" do

    access_token = create(:access_token)
    group = create(:group, name: "sysadmins")
    user = create(:user)
    user.groups << group

    post "add_host", params: { token: access_token.token, name: "random_host_01", group_name: "random_group_01", format: :json}
    host = HostMachine.first
    expect(host.name).to eq "random_host_01"
    host.groups << group


    get "group", params: { token: host.access_key, format: :json }
    body = JSON.parse(response.body)

    expect(body.count).to eq 2
    expect(body[0]["gr_mem"].count).to eq 1
    expect(body[1]["gr_mem"].count).to eq 1

    expect(body[0]["gr_mem"][0]).to eq user.user_login_id
    expect(body[1]["gr_mem"][0]).to eq user.user_login_id


  end

  it "should not return sysadmins if inheritance is off" do

    access_token = create(:access_token)
    group = create(:group, name: "sysadmins")
    group_2 = create(:group, name: "random")
    user = create(:user)
    user.groups << group_2
    user_2 = create(:user)
    user_2.groups << group

    post "add_host", params: { token: access_token.token, name: "random_host_01", group_name: "random_group_01", default_admins: false, format: :json}
    host = HostMachine.first
    expect(host.name).to eq "random_host_01"
    host.groups << group_2


    get "group", params: { token: host.access_key, format: :json }
    body = JSON.parse(response.body)

    expect(body.count).to eq 2
    expect(body[0]["gr_mem"].count).to eq 1
    expect(body[1]["gr_mem"].count).to eq 1

    expect(body[0]["gr_mem"][0]).to eq user.user_login_id
    expect(body[1]["gr_mem"][0]).to eq user.user_login_id


  end

  it "should return all the users for the host" do

    access_token = create(:access_token)
    group = create(:group, name: "sysadmins")
    user = create(:user)
    user.groups << group

    post "add_host", params: { token: access_token.token, name: "random_host_01", group_name: "random_group_01", format: :json}
    host = HostMachine.first
    expect(host.name).to eq "random_host_01"
    host.groups << group

    host.reload
    group.reload
    user.reload


    get "passwd", params: { token: host.access_key, format: :json }
    body = JSON.parse(response.body)
    expect(body.count).to eq 1
    get "passwd", params: { token: host.access_key, format: :json }
    body = JSON.parse(response.body)
    expect(body.count).to eq 1
  end

  it "should burst host machine cache if member is added or removed" do
    group = create(:group)
    user = create(:user)
    host_machine = create(:host_machine)
    host_machine.groups << group
    user.groups << group
    host_machine.save!

    Group.all.each do |group|
      group.burst_host_cache
    end

    cache_count_bfr = REDIS_CACHE.keys("UG*").count

    get "group", params: { token: host_machine.access_key, format: :json }
    cache_count_aft = REDIS_CACHE.keys("UG*").count

    expect(cache_count_aft).to eq cache_count_bfr + 1
    group.burst_host_cache

    cache_count_aft = REDIS_CACHE.keys("UG*").count
    expect(cache_count_aft).to eq cache_count_bfr + 1

  end


end
