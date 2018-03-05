require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  describe 'Search for Groups' do
    it "should return groups according to supplied search string" do
      groups = create_list(:group, 3)
      get :search, { q: "People" }
      expect(JSON.parse(response.body)).to eq(groups.map{|m| {"id" => m.id, "name" => m.name}})
    end
  end
end
