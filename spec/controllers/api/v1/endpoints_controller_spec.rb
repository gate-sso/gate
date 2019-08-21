require 'rails_helper'

describe ::Api::V1::EndpointsController, type: :controller do
  let(:admin) do
    admin = build(:admin_user)
    admin.access_token = build(:access_token)
    admin.save!
    admin
  end
  let(:valid_attributes) do
    {
      path: '/',
      method: 'GET',
    }
  end

  describe '#create' do
    context 'given valid param' do
      it 'should return http status 200' do
        post :create, params: { endpoint: valid_attributes, access_token: admin.access_token.token }
        expect(response).to have_http_status(200)
      end

      it 'should create endpoint' do
        post :create, params: { endpoint: valid_attributes, access_token: admin.access_token.token }
        endpoint = Endpoint.find_by(valid_attributes)
        expect(endpoint).not_to be nil
      end

      it 'should return proper response' do
        post :create, params: { endpoint: valid_attributes, access_token: admin.access_token.token }
        endpoint = Endpoint.find_by(valid_attributes)
        expect(response.body).to eq({
          id: endpoint.id,
          path: endpoint.path,
          method: endpoint.method,
        }.to_json)
      end
    end

    context 'given invalid param' do
      it 'should return http status 422' do
        invalid_attributes = valid_attributes
        invalid_attributes[:method] = 'JUMP'
        post :create, params: { endpoint: invalid_attributes, access_token: admin.access_token.token }
        expect(response).to have_http_status(422)
      end
    end
  end
end
