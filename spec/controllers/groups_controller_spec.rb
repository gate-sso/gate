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

  describe 'GET #show' do
    context 'unauthenticated' do
      it 'should return 302' do
        get :index

        expect(response).to have_http_status(302)
      end
    end

    context 'authenticated as admin' do
      context '' do
        it 'should return specified group' do
          sign_in admin
          group = create(:group)
          get :show, params: { id: group.id }
          expect(response).to have_http_status(200)
        end

        it 'should populate group_users instance variable' do
          sign_in admin
          user = create(:user)
          group = create(:group)
          create(:group_association, group_id: group.id, user_id: user.id, expiration_date: '2020-01-01')
          get :show, params: { id: group.id }
          expect(assigns(:group_users).first.to_json).to eq(
            {
              id: user.id,
              email: user.email,
              name: user.name,
              active: user.active,
              group_expiration_date: '2020-01-01'
            }.to_json
          )
        end
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

      it 'should add user to group with expiration date' do
        sign_in admin
        group = create(:group)
        date = '2019-07-10'

        post :add_user, params: { id: group.id, user_id: user.id, expiration_date: date }

        group_association = group.group_associations.where(user_id: user.id).take
        expect(group_association.expiration_date).to eq(Date.parse(date))
      end

      context 'wrong expiration date param' do
        it 'should flash error message' do
          sign_in admin
          group = create(:group)
          date = 'this is not a date'

          post :add_user, params: { id: group.id, user_id: user.id, expiration_date: date }

          expect(flash[:notice]).to eq('Expiration date is wrong')
        end
      end

      context 'empty expiration date' do
        it 'should add user to group without expiration' do
          sign_in admin
          group = create(:group)
          date = ''

          post :add_user, params: { id: group.id, user_id: user.id, expiration_date: date }

          group_association = group.group_associations.where(user_id: user.id).take
          expect(group_association.expiration_date).to eq(nil)
        end
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

      it 'should add user with expiration date' do
        sign_in admin
        group = create(:group)
        date = '2019-06-24'

        post :add_group, params: { id: user.id, group_id: group.id, expiration_date: date }

        group_association = group.group_associations.where(user_id: user.id).take
        expect(group_association.expiration_date).to eq(Date.parse(date))
      end

      context 'wrong expiration date param' do
        it 'should flash error message' do
          sign_in admin
          group = create(:group)
          date = 'this is not a date'

          post :add_group, params: { id: user.id, group_id: group.id, expiration_date: date }

          expect(flash[:notice]).to eq('Expiration date is wrong')
        end

        it 'should not add user to group' do
          sign_in admin
          group = create(:group)
          date = 'this is not a date'

          post :add_group, params: { id: user.id, group_id: group.id, expiration_date: date }

          expect(group.users).not_to include(user)
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
