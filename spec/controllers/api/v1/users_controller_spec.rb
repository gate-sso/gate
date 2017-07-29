require 'rails_helper'

RSpec.describe ::Api::V1::UsersController, type: :controller do

  let(:valid_attributes) {
    {name: "jumbo", email: "jumbo.aux"}
  }

  describe 'Authentication' do

    context "with valid_attributes" do
      it "should create users" do
        post :create,  {user: valid_attributes, "access_token": "my_secret"}
        expect(response.status).to eq(200)
        user = User.first
        expect(User.count).to eq(1)
        expect(user.name).to eq("jumbo")
      end
    end
  end


  describe 'UnAuthentication' do
    it 'gives 401 when access token is in valid' do
      post :create,  {user: valid_attributes, "access_token": "foo"}
      expect(response.status).to eq(401)
    end
  end
end

