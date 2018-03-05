require 'rails_helper'

RSpec.describe HostMachinesController, type: :controller do
  describe 'Search for Hosts' do
    it "should return hosts according to supplied search string" do
      host_machines = create_list(:host_machine, 3)
      get :search, { q: "host" }
      expect(JSON.parse(response.body)).to eq(host_machines.map{|m| {"id" => m.id, "name" => m.name}})
    end
  end
end
