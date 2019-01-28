require 'rails_helper'

RSpec.describe ::Api::V1::VpnsController, type: :controller do
  let(:valid_attributes) {
    {name: 'jumbo'}
  }

  before(:each) do
    @user = build(:user)
    @user.access_token = build(:access_token)
    @user.save
    @token = @user.access_token.token
  end

  describe 'Authenticated' do
    describe 'Create Vpn' do
      context 'with valid_attributes' do
        it 'should create vpns' do
          post :create,  params: {vpn: valid_attributes, access_token: @token}
          expect(response.status).to eq(200)
          vpn = Vpn.where(name: valid_attributes[:name]).first
          expect(vpn.blank?).to eq(false)
          expect(vpn.name).to eq(valid_attributes[:name])
        end
      end
    end
  end

  describe 'Unauthenticated' do
    it 'gives 401 when access token is invalid' do
      post :create,  params: {vpn: valid_attributes, access_token: 'foo'}
      expect(response.status).to eq(401)
    end
  end
end
