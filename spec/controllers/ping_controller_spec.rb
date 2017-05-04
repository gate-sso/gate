require "rails_helper"

RSpec.describe PingController, type: :controller do
  describe "#ping" do
    it "should return a blank body" do
      get :ping
      expect(response).to have_http_status(200)
      expect(response.body).to eq("")
    end
  end
end
