require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  let(:product_name) { 'product-name'  }
  let(:admin) { create(:admin_user) }
  let(:user) { create(:user, name: 'foobar', user_login_id: 'foobar', email: 'foobar@foobar.com') }

  describe 'GET #index' do
    context 'unauthenticated' do
      it 'should return 302' do
        get :index

        expect(response).to have_http_status(302)
      end
    end

    context 'authenticated as admin' do
      context 'without search param' do
        it 'should not return any group' do
          sign_in admin
          create_list(:group, 3)

          get :index

          expect(assigns(:groups).size).to eq(0)
        end
      end
    end
  end

  describe 'Search for Groups' do
    it 'should return groups according to supplied search string' do
      sign_in user
      groups = create_list(:group, 3)
      get :search, params: { q: 'People' }
      expect(JSON.parse(response.body)).to eq(groups.map { |m| { 'id' => m.id, 'name' => m.name } })
    end
  end
end
