require 'rails_helper'

RSpec.describe ::Api::V1::GroupsController, type: :controller do
  before(:each) do
    @user = build(:user)
    @user.access_token = build(:access_token)
    @user.save
    @token = @user.access_token.token
  end

  describe 'Search for Groups' do
    it "should return groups according to supplied search string" do
      groups = create_list(:group, 3)
      get :search, { email: @user.email, access_token: @token, q: "People" }
      expect(JSON.parse(response.body)).to eq(groups.map{|m| {"id" => m.id, "name" => m.name}})
    end
  end
end
