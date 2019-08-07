require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:product_name) { "product-name"  }
  let!(:group) { FactoryBot.create(:group)  }
  let(:user) { FactoryBot.create(:user, name: "foobar", user_login_id: "foobar", email: "foobar@foobar.com")  }

  describe 'GET #show' do
    context 'unauthenticated' do
      it 'should return 302' do
        get :index

        expect(response).to have_http_status(302)
      end
    end

    context 'authenticated' do
      it 'should return specified user' do
        sign_in user
        get :show, params: { id: user.id }
        expect(response).to have_http_status(200)
      end

      it 'should populate user_groups instance variable' do
        sign_in user
        create(:group_association, group_id: group.id, user_id: user.id, expiration_date: '2020-01-01')
        get :show, params: { id: user.id }
        expected_group = assigns(:user_groups).select { |user_group| user_group.id == group.id }
        expect(expected_group.first.to_json).to eq(
          {
            id: group.id,
            name: group.name,
            gid: group.gid,
            deleted_at: group.deleted_at,
            group_expiration_date: '2020-01-01',
          }.to_json
        )
      end
    end
  end

  describe 'POST #create' do
    context 'unauthenticated' do
      it 'should return 302 http status' do
        post :create

        expect(response).to have_http_status(302)
      end
    end
  end

  context "update user profile" do
    it "should update profile with product name" do
      sign_in user

      patch :update, params: { id: user.id, product_name: product_name }

      user.reload
      expect(user.product_name).to eq(product_name)
    end

    it "should return 302" do
      sign_in user

      patch :update, params: { id: user.id, product_name: product_name }

      expect(response).to have_http_status(302)
    end

    it "should redirect to same page once the profile is updated" do
      sign_in user

      patch :update, params: { id: user.id, product_name: product_name }

      expect(response).to redirect_to(user_path)
    end

    context "for invalid request" do
      it "should return params missing message on flash" do
        sign_in user

        patch :update, params: { id: user.id }

        expect(flash[:notice]).to eq("Params are missing")
      end
    end
  end

  describe 'Search for Users' do
    it "should return only active users by default according to query" do
      sign_in user
      users = create_list(:user, 3)
      users.last.update(active: false)
      get :search, params: { q: users.first.name }
      returned_ids = JSON.parse(response.body).collect{|c| c['id']}
      expect(returned_ids).to eq([users.first.id])
    end

    it "should return users according to query, if we supplied include_inactive params" do
      sign_in user
      users = create_list(:user, 3)
      users.last.update(active: false)
      get :search, params: { q: users.last.name, include_inactive: 'true' }
      returned_ids = JSON.parse(response.body).collect{|c| c['id']}
      expect(returned_ids).to eq([users.last.id])
    end
  end

  describe "GET #regenerate_token" do
    before(:each) do
      access_token = AccessToken.new
      access_token.token = ROTP::Base32.random_base32
      access_token.user = user
      access_token.save!

      sign_in user
    end

    it "regenerates access token of the requested user" do
      old_hashed_token = user.access_token.hashed_token
      get :regenerate_token, params: {:id => user.to_param}
      user.reload
      expect(user.access_token.hashed_token).to_not eq old_hashed_token
    end

    it "redirects to the user" do
      get :regenerate_token, params: {:id => user.to_param}
      expect(response).to redirect_to(user_path(user.id))
    end
  end
end
