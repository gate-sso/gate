require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  let(:product_name) { 'product-name'  }
  let!(:admin) { create(:admin_user) }
  let(:user) do
    create(:user, name: 'foobar', user_login_id: 'foobar', email: 'foobar@foobar.com', admin: false)
  end

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

      context 'with search param' do
        it 'should return correct groups' do
          sign_in admin
          group_foo = create(:group, name: 'GroupFoo')
          group_foobar = create(:group, name: 'GroupFoobar')
          create(:group, name: 'GroupBar')

          get :index, params: { group_search: 'Foo' }

          expect(assigns(:groups)).to contain_exactly(group_foo, group_foobar)
        end
      end
    end

    context 'authenticated as group admin' do
      it 'should return its groups only' do
        sign_in user
        group_foo = create(:group, name: 'GroupFoo')
        group_foobar = create(:group, name: 'GroupFoobar')
        group_foo.add_admin user
        group_foobar.add_admin user
        create(:group, name: 'GroupBar')

        get :index

        expect(assigns(:groups)).to contain_exactly(group_foo, group_foobar)
      end
    end
  end

  describe 'POST #add_user' do
    context 'unauthenticated' do
      it 'should return 302' do
        group = create(:group)

        post :add_user, params: { id: group.id }

        expect(response).to have_http_status(302)
      end
    end

    context 'authenticated as admin' do
      it 'should add user to group' do
        sign_in admin
        group = create(:group)

        post :add_user, params: { id: group.id, user_id: user.id }

        expect(group.users).to include(user)
      end
    end

    context 'authenticated as group admin' do
      it 'should add new user to group' do
        sign_in user
        group = create(:group)
        group.add_admin(user)
        new_user = create(:user)

        post :add_user, params: { id: group.id, user_id: new_user.id }

        expect(group.users).to include(new_user)
      end
    end
  end

  describe 'POST #add_group' do
    context 'unauthenticated' do
      it 'should return 302' do
        group = create(:group)

        post :add_group, params: { id: user.id, group_id: group.id }

        expect(response).to have_http_status(302)
      end
    end

    context 'authenticated as admin' do
      it 'should add user to group' do
        sign_in admin
        group = create(:group)

        post :add_group, params: { id: user.id, group_id: group.id }

        expect(group.users).to include(user)
      end

      it 'should redirect to user path once user added to group' do
        sign_in admin
        group = create(:group)

        post :add_group, params: { id: user.id, group_id: group.id }

        expect(response).to redirect_to(user_path)
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
