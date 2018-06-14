require 'rails_helper'

RSpec.describe ProfileController, type: :controller do

  let(:user) { FactoryBot.create(:user, name: "foobar", admin: true, user_login_id: "foobar", email: "foobar@foobar.com")  }

  context "mfa" do
    it "should recreate auth" do

      #we should choose to stub the authentication with the method given here
      #https://github.com/plataformatec/devise/wiki/How-To:-Stub-authentication-in-controller-specs
      #but this requires to hand post create call in users and breaks some old tests.
      #we need to fix those.
      sign_in user

      auth_key = user.auth_key
      get :regen_auth

      user.reload

      expect(response.status).to eq(302)
      expect(auth_key).to_not eq(user.auth_key)

    end
  end



end
