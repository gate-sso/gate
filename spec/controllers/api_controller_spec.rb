require 'rails_helper'

RSpec.describe ApiController, type: :controller do

  controller(ApiController) do
    def index
      head :ok
    end
  end

  describe 'Authentication' do
    it 'gives 200 when access token is valid' do
      get :index, access_token: "my_secret"

      expect(response.status).to eq(200)
    end

    it 'gives 401 when access token is in valid' do
      get :index, access_token: "foo"

      expect(response.status).to eq(401)
    end
    end
end

