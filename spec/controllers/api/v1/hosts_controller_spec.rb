require 'rails_helper'

RSpec.describe ::Api::V1::HostsController, type: :controller do
  before(:each) do
    @user = build(:user)
    @user.access_token = build(:access_token)
    @user.save
    @token = @user.access_token.token
  end

  describe 'Search for Hosts' do
    it "should return hosts according to supplied search string" do
      host_machines = create_list(:host_machine, 3)
      get :search, { email: @user.email, access_token: @token, q: "host" }
      expect(JSON.parse(response.body)).to eq(host_machines.map{|m| {"id" => m.id, "name" => m.name}})
    end
  end
end
