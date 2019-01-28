require 'rails_helper'

RSpec.describe ::Api::V1::BaseController, type: :controller do

  controller(::Api::V1::BaseController) do
    def index
      head :ok
    end
  end

  describe 'Authentication' do
    before(:each) do
      @user = build(:user)
      @user.access_token = build(:access_token)
      @user.save
      @token = @user.access_token.token
    end
    it 'gives 200 when access token is valid' do
      get :index, params: { access_token: @token }
      expect(response.status).to eq(200)
    end

    it 'gives 401 when access token is in valid' do
      get :index, params: { access_token: "foo" }
      expect(response.status).to eq(401)
    end
  end
end
