require 'rails_helper'

RSpec.describe ::Api::V1::VpnsController, type: :controller do
  before(:each) do
    @user = build(:user)
    @user.access_token = build(:access_token)
    @user.save
    @token = @user.access_token.token
  end

  describe 'Search for Vpns' do
    it "should return vpns according to supplied search string" do
      vpns = create_list(:vpn, 3)
      get :search, { email: @user.email, access_token: @token, q: "VPN" }
      expect(JSON.parse(response.body)).to eq(vpns.map{|m| {"id" => m.id, "name" => m.name}})
    end
  end
end
