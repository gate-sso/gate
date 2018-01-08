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

  describe 'User Details' do
    context 'success' do
      it 'should return 200 http status code' do
        group = FactoryGirl.create(:group)
        user =  FactoryGirl.create(:user, name: "foo", user_login_id: "foob", email: "foo@foobar.com", reset_password_token: "test1")

        get :show, { email: user.email, "access_token": "my_secret" }

        expect(response.status).to eq(200)
      end

      it 'should return the user details' do
        group = FactoryGirl.create(:group)
        user =  FactoryGirl.create(:user, name: "foo", user_login_id: "foob", email: "foo@foobar.com", reset_password_token: "test1", product_name: "fooproduct")

        get :show, { email: user.email, "access_token": "my_secret" }

        reponse_json = JSON(response.body)
        expect(reponse_json["user"]["product_name"]).to eq(user.product_name)
      end
    end

    context 'failure' do
      it 'should return the user details' do
        group = FactoryGirl.create(:group)
        user =  FactoryGirl.create(:user, name: "foo", user_login_id: "foob", email: "foo@foobar.com", reset_password_token: "test1", product_name: "fooproduct")

        get :show, { email: "test@test.com", "access_token": "my_secret" }

        expect(response.status).to eq(404)
      end
    end
  end
end
