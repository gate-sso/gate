require 'rails_helper'

describe ::Api::V1::EndpointsController, type: :controller do
  before(:each) do
    @admin = build(:admin_user)
    @admin.access_token = build(:access_token)
    @admin.save!
    @admin_token = @admin.access_token.token
  end

  let(:valid_attributes) do
    {
      path: '/',
      method: 'GET',
    }
  end

  describe '#create' do
    context 'authenticated as admin' do
      context 'given valid param' do
        it 'should return http status 200' do
          post :create, params: { endpoint: valid_attributes, access_token: @admin_token }
          expect(response).to have_http_status(200)
        end

        it 'should create endpoint' do
          post :create, params: { endpoint: valid_attributes, access_token: @admin_token }
          endpoint = Endpoint.find_by(valid_attributes)
          expect(endpoint).not_to be nil
        end

        it 'should return proper response' do
          post :create, params: { endpoint: valid_attributes, access_token: @admin_token }
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
          post :create, params: { endpoint: invalid_attributes, access_token: @admin_token }
          expect(response).to have_http_status(422)
        end

        it 'should return proper response' do
          invalid_attributes = valid_attributes
          invalid_attributes[:method] = 'JUMP'
          invalid_attributes[:path] = 'not-a-path'
          post :create, params: { endpoint: invalid_attributes, access_token: @admin_token }
          response_body = JSON.parse response.body
          expect(response_body['status']).to include('method', 'path')
        end
      end
    end

    context 'unauthenticated' do
      it 'should return http status 401' do
        post :create, params: { endpoint: valid_attributes }
        expect(response.status).to eq(401)
      end
    end
  end

  describe '#add_group' do
    context 'authenticated as admin' do
      context 'given valid group id' do
        it 'should return http status 200' do
          endpoint = create(:endpoint)
          group = create(:group)
          post :add_group, params: { id: endpoint.id, group: { id: group.id }, access_token: @admin_token }
          expect(response).to have_http_status 200
        end
      end
    end
  end
end
