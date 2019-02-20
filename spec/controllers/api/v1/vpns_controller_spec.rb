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
          vpn = Vpn.where(name: valid_attributes[:name]).first
          expect(vpn.blank?).to eq(false)
          expect(vpn.name).to eq(valid_attributes[:name])
          expect(UUID.validate(vpn.uuid)).to eq(true)
        end

        it 'should return proper response' do
          post :create,  params: {vpn: valid_attributes, access_token: @token}
          expect(response.status).to eq(200)
          vpn = Vpn.where(name: valid_attributes[:name]).first
          obj = JSON.parse(response.body)
          expect(obj['id']).to eq vpn.id
          expect(obj['name']).to eq vpn.name
          expect(obj['host_name']).to eq vpn.host_name
          expect(obj['ip_address']).to eq vpn.ip_address
        end
      end
    end

    describe 'Assign Group to VPN' do
      it 'should replace existing vpn group with new group' do
        vpn = create(:vpn)
        group_1 = create(:group)
        group_2 = create(:group)
        vpn.groups << group_1
        vpn.groups << group_2
        group_3 = create(:group)
        post :assign_group,  params: {access_token: @token, id: vpn.id, group_id: group_3.id}
        expect(vpn.groups.count).to eq 1
        expect(vpn.groups.first).to eq group_3
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
