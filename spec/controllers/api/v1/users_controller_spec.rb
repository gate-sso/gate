require 'rails_helper'

RSpec.describe ::Api::V1::UsersController, type: :controller do

  let(:valid_attributes) {
    {name: "jumbo", email: "jumbo.aux"}
  }
  before(:each) do
    @user = build(:user)
    @user.access_token = build(:access_token)
    @user.save
    @token = @user.access_token.token
  end
  describe 'Authentication' do
    context "with valid_attributes" do
      it "should create users" do
        post :create,  params: {user: valid_attributes, "access_token": @token}
        expect(response.status).to eq(200)
        user = User.where(name: valid_attributes[:name]).first
        expect(user.blank?).to eq(false)
        expect(user.name).to eq(valid_attributes[:name])
      end
    end
  end

  describe 'UnAuthentication' do
    it 'gives 401 when access token is in valid' do
      post :create,  params: {user: valid_attributes, "access_token": "foo"}
      expect(response.status).to eq(401)
    end
  end

  describe 'Update Profile' do
    context 'authenticated as admin' do
      it 'should return 200 http status code' do
        user = create(:user)
        access_token = create(:access_token, token: SecureRandom.uuid)
        user.access_token = access_token
        require 'openssl'
        rsa_key = OpenSSL::PKey::RSA.new(2048)
        public_key = rsa_key.public_key.to_pem
        name = 'test_name'
        product_name = 'test_product'
        post :update, params: {
          access_token: access_token.token,
          public_key: public_key,
          product_name: product_name,
          name: name,
          email: user.email,
        }
        expect(response.status).to eq(200)
      end
    end

    context 'authenticated as non admin' do
      it 'should return 401 http status code' do
        user = create(:user, admin: false)
        user.access_token = create(:access_token, token: SecureRandom.uuid)
        target_user = create(:user)
        require 'openssl'
        rsa_key = OpenSSL::PKey::RSA.new(2048)
        public_key = rsa_key.public_key.to_pem
        name = 'test_name'
        product_name = 'test_product'
        post :update, params: {
          access_token: user.access_token.token,
          public_key: public_key,
          product_name: product_name,
          name: name,
          email: target_user.email,
        }
        expect(response.status).to eq(401)
      end
    end

    context 'authenticated as itself' do
      it 'should return 200 http status code' do
        user = create(:user, admin: false)
        access_token = create(:access_token, token: SecureRandom.uuid)
        user.access_token = access_token
        require 'openssl'
        rsa_key = OpenSSL::PKey::RSA.new(2048)
        public_key = rsa_key.public_key.to_pem
        name = 'test_name'
        product_name = 'test_product'
        post :update, params: {
          access_token: access_token.token,
          public_key: public_key,
          product_name: product_name,
          name: name,
          email: user.email,
        }
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'User Details' do
    context 'success' do
      it 'should return 200 http status code' do
        group = FactoryBot.create(:group)
        user =  FactoryBot.create(:user, name: "foo", user_login_id: "foob", email: "foo@foobar.com", reset_password_token: "test1")
        get :show, params: { email: user.email, "access_token": @token, :format => :json }
        expect(response.status).to eq(200)
      end

      it 'should return the user details' do
        group = FactoryBot.create(:group)
        user =  FactoryBot.create(:user, name: "foo", user_login_id: "foob", email: "foo@foobar.com", reset_password_token: "test1", product_name: "fooproduct")
        get :show, params: { email: user.email, "access_token": @token, :format => :json }
        reponse_json = JSON(response.body)
        expect(reponse_json["product_name"]).to eq(user.product_name)
      end

      it 'should not display user secrets' do
        group = FactoryBot.create(:group)
        user =  FactoryBot.create(:user, name: "foo", user_login_id: "foob", email: "foo@foobar.com", reset_password_token: "test1", product_name: "fooproduct", created_at: "2018-01-11T21:30:41.000Z", updated_at: "2018-01-11T21:30:41.000Z")
        get :show, params: { email: user.email, "access_token": @token, :format => :json }
        response_json = JSON(response.body)
        %w(
          email uid name active admin home_dir shell public_key user_login_id
          product_name groups
        ).each do |col|
          expect(response_json.keys.include?(col)).to eq(true)
        end
      end

      it 'should display active user' do
        FactoryBot.create(:user, name: 'foo', active: 0, user_login_id: 'foo', email: 'foo@foobar.com')
        active_user = FactoryBot.create(:user, name: 'foo', user_login_id: 'foo', email: 'foo@bar.com')

        get :show, params: { username: 'foo', active: 1, 'access_token': @token, :format => :json }

        response_json = JSON(response.body)
        expect(response_json['email']).to eq(active_user.email)
      end

      it 'should display active user when query parameter active is true' do
        FactoryBot.create(:user, name: 'foo', active: 0, user_login_id: 'foo', email: 'foo@foobar.com')
        active_user = FactoryBot.create(:user, name: 'foo', user_login_id: 'foo', email: 'foo@bar.com')

        get :show, params: { username: 'foo', active: true, 'access_token': @token, :format => :json }

        response_json = JSON(response.body)
        expect(response_json['email']).to eq(active_user.email)
      end

      it 'should display inactive user when query parameter active is false' do
        inactive_user = FactoryBot.create(:user, name: 'foo', active: 0, user_login_id: 'foo', email: 'foo@foobar.com')
        FactoryBot.create(:user, name: 'foo', user_login_id: 'foo', email: 'foo@bar.com')

        get :show, params: { username: 'foo', active: false, 'access_token': @token, :format => :json }

        response_json = JSON(response.body)
        expect(response_json['email']).to eq(inactive_user.email)
      end
    end

    context 'failure' do
      it 'should return http status code 404' do
        group = FactoryBot.create(:group)
        user =  FactoryBot.create(:user, name: "foo", user_login_id: "foob", email: "foo@foobar.com", reset_password_token: "test1", product_name: "fooproduct")
        get :show, params: { email: "test@test.com", "access_token": @token, :format => :json }
        expect(response.status).to eq(404)
      end

      it 'should not authenticate user for invalid acces token' do
        group = FactoryBot.create(:group)
        user =  FactoryBot.create(:user, name: "foo", user_login_id: "foob", email: "foo@foobar.com", reset_password_token: "test1", product_name: "fooproduct")

        get :show, params: { email: "test@test.com", "access_token": "invalid_access_token" }

        expect(response.status).to eq(401)
      end
    end
  end
end
