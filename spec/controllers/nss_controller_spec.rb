require 'rails_helper'

RSpec.describe NssController, type: :controller do
	let(:access_token) { SecureRandom.uuid }
	let(:email) { Faker::Internet.email }
	before(:each) do
    group = create(:group)
  end
	it "should return false for invalid token" do
		get :groups_list, token: access_token, email: email
		data = JSON.parse(response.body)
		expect(data["success"]).to eq(false)
	end

	it "should return false for not registered email" do
		create(:access_token, token: access_token)
		get :groups_list, token: access_token, email: email
		data = JSON.parse(response.body)
		expect(data["success"]).to eq(false)
	end

	it "should return group list for registered email" do
		create(:access_token, token: access_token)
		create(:user, email: email)
		get :groups_list, token: access_token, email: email
		data = JSON.parse(response.body)
		expect(data["success"]).to eq(true)
	end	
end
