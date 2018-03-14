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

    it "should add or remove properties" do
      sign_in user

      @vpn01 = Vpn.create(name: "z")

      post :add_dns_server, { id: @vpn01.id, server_address: '1.1.1.1'} 
      expect(@vpn01.vpn_domain_name_servers.count).to eq(1)

      post :remove_dns_server, { id: @vpn01.id, vpn_domain_name_server_id: @vpn01.vpn_domain_name_servers.first.id} 
      expect(@vpn01.vpn_domain_name_servers.count).to eq(0)

      post :add_search_domain, { id: @vpn01.id, search_domain: 'xyz.com'} 
      expect(@vpn01.vpn_search_domains.count).to eq(1)

      post :remove_search_domain, { id: @vpn01.id, vpn_search_domain_id: @vpn01.vpn_search_domains.first.id} 
      expect(@vpn01.vpn_search_domains.count).to eq(0)

      post :add_supplemental_match_domain, { id: @vpn01.id, supplemental_match_domain: 'abc.co.id'} 
      expect(@vpn01.vpn_supplemental_match_domains.count).to eq(1)

      post :remove_supplemental_match_domain, { id: @vpn01.id, vpn_supplemental_match_domain_id: @vpn01.vpn_supplemental_match_domains.first.id} 
      expect(@vpn01.vpn_supplemental_match_domains.count).to eq(0)

    end
  end

  describe 'Search for Vpns' do
    it "should return vpns according to supplied search string" do
      sign_in user
      vpns = create_list(:vpn, 3)
      get :search, { q: "VPN" }
      expect(JSON.parse(response.body)).to eq(vpns.map{|m| {"id" => m.id, "name" => m.name}})
    end
  end
end

