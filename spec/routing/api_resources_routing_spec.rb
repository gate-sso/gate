require "rails_helper"

RSpec.describe ApiResourcesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/api_resources").to route_to("api_resources#index")
    end

    it "routes to #new" do
      expect(:get => "/api_resources/new").to route_to("api_resources#new")
    end

    it "routes to #show" do
      expect(:get => "/api_resources/1").to route_to("api_resources#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/api_resources/1/edit").to route_to("api_resources#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/api_resources").to route_to("api_resources#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/api_resources/1").to route_to("api_resources#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/api_resources/1").to route_to("api_resources#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/api_resources/1").to route_to("api_resources#destroy", :id => "1")
    end

  end
end
