require 'rails_helper'
include Devise::TestHelpers

RSpec.describe UsersController, type: :controller do
  let(:product_name) { "product-name"  }
  let!(:group) { FactoryGirl.create(:group)  }
  let(:user) { FactoryGirl.create(:user, name: "foobar", user_login_id: "foobar", email: "foobar@foobar.com")  }

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

      response.should redirect_to user_path
    end

    context "for invalid request" do
      it "should return params missing message on flash" do
        sign_in user

        patch :update, id: user.id

        expect(flash[:notice]).to eq("Params are missing")
      end
    end
  end
end
