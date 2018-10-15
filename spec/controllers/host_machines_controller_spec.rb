require 'rails_helper'

RSpec.describe HostMachinesController, type: :controller do

  let(:user) { FactoryBot.create(:user, name: "foobar", user_login_id: "foobar", email: "foobar@foobar.com")  }
  describe 'Search for Hosts' do
    it "should return hosts according to supplied search string" do
      sign_in user
      host_machines = create_list(:host_machine, 3)
      get :search, params: { q: "host" }
      expect(JSON.parse(response.body)).to eq(host_machines.map{|m| {"id" => m.id, "name" => m.name}})
    end
  end
end
