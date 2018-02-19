require 'rails_helper'

RSpec.describe VpnsController, type: :controller do

  let(:user) { FactoryBot.create(:user, name: "foobar", admin: true, user_login_id: "foobar", email: "foobar@foobar.com")  }
  context "vpn operations" do
    it "should return sorted vpns" do

      #we should choose to stub the authentication with the method given here
      #https://github.com/plataformatec/devise/wiki/How-To:-Stub-authentication-in-controller-specs
      #but this requires to hand post create call in users and breaks some old tests.
      #we need to fix those.
      sign_in user

      @vpn01 = Vpn.create(name: "z")
      @vpn02 = Vpn.create(name: "a")


      vpns = [ @vpn02, @vpn01]

      get :index

      expect(response).to render_template("index")
      expect(response.status).to eq(200)
      expect(assigns(:vpns)).to eq(vpns)


      @vpn03 = Vpn.create(name: "c")
      vpns = [ @vpn02, @vpn03, @vpn01]
      get :index
      expect(assigns(:vpns)).to eq(vpns)

      @vpn04 = Vpn.create(name: "b")

      vpns = [ @vpn02, @vpn04, @vpn03, @vpn01]
      get :index
      expect(assigns(:vpns)).to eq(vpns)

    end
  end
end

