require 'rails_helper'

describe ::Api::V1::EndpointsController, type: :controller do
  let(:valid_attributes) do
    {
      path: '/',
      method: 'GET',
    }
  end

  describe '#create' do
    context 'given valid param' do
      it 'should return http status 200' do
        admin = build(:admin_user)
        admin.access_token = build(:access_token)
        admin.save
        post :create, params: { endpoint: valid_attributes, access_token: admin.access_token.token }
        expect(response).to have_http_status(200)
      end

      it 'should create endpoint' do
        admin = build(:admin_user)
        admin.access_token = build(:access_token)
        admin.save
        post :create, params: { endpoint: valid_attributes, access_token: admin.access_token.token }
        endpoint = Endpoint.find_by(valid_attributes)
        expect(endpoint).not_to be nil
      end
    end
  end
end
