require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:product_name) { "product-name"  }
  let!(:group) { FactoryBot.create(:group)  }
  let(:user) { FactoryBot.create(:user, name: "foobar", user_login_id: "foobar", email: "foobar@foobar.com")  }

  context "update user profile" do
    it "should update profile with product name" do
      sign_in user

      patch :update, id: user.id, product_name: product_name

      user.reload
      expect(user.product_name).to eq(product_name)
    end

    it "should return 302" do
      sign_in user

      patch :update, id: user.id, product_name: product_name

      expect(response).to have_http_status(302)
    end

    it "should redirect to same page once the profile is updated" do
      sign_in user

      patch :update, id: user.id, product_name: product_name

      expect(response).to redirect_to(user_path)
    end

    context "for invalid request" do
      it "should return params missing message on flash" do
        sign_in user

        patch :update, id: user.id

        expect(flash[:notice]).to eq("Params are missing")
      end
    end
  end

  describe 'Search for Users' do
    it "should return users according to supplied search string" do
      users = create_list(:user, 3)
      get :search, { q: "TestUser" }
      returned_ids = JSON.parse(response.body).collect{|c| c['id']}
      expect(returned_ids).to eq(users.collect(&:id))
    end
  end
end
