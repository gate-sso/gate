require 'rails_helper'

RSpec.describe ::Api::V1::GroupsController, type: :controller do
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
    describe 'Create Group' do
      context 'with valid_attributes' do
        it 'should create groups' do
          post :create,  params: {group: valid_attributes, access_token: @token}
          expect(response.status).to eq(200)
          group = Group.where(name: valid_attributes[:name]).first
          expect(group.blank?).to eq(false)
          expect(group.name).to eq(valid_attributes[:name])
        end
      end
    end
  end

  describe 'Unauthenticated' do
    it 'gives 401 when access token is invalid' do
      post :create,  params: {group: valid_attributes, access_token: 'foo'}
      expect(response.status).to eq(401)
    end
  end
end
