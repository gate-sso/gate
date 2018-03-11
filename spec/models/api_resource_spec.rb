require 'rails_helper'

RSpec.describe ApiResource, type: :model do
  let(:user) {
    FactoryBot.create(:user,
      name: "foobar",
      admin: true,
      user_login_id: "foobar",
      email: "foobar@foobar.com"
    )
  }
  let(:group) { FactoryBot.create(:group, name: "foobar_group") }
  let(:valid_attributes) do
    {
      name: "sample_api",
      description: "sample_api_description",
      access_key: "xcz",
      user_id: user.id,
      group_id: group.id
    }
  end

  describe "self.authenticate" do
    it "should return true if it finds matching access_key and the user is member of the group" do
      api_resource = ApiResource.create(valid_attributes)
      group.users << user
      access_token = AccessToken.new
      access_token.token = ROTP::Base32.random_base32
      access_token.user = user
      access_token.save!
      expect(ApiResource.authenticate(valid_attributes[:access_key], access_token.token)).to eq true
    end
  end

  describe "hash_access_key! before_save" do
    it "should hash access_key and put it into hashed_access_key" do
      api_resource = ApiResource.create(valid_attributes)
      expect(api_resource.hashed_access_key).to eq(
        Digest::SHA512.hexdigest(valid_attributes[:access_key]))
    end

    it "shouldn't change hashed_access_key if access_key isn't supplied" do
      api_resource = ApiResource.create(valid_attributes)
      api_resource.update(description: "Change Description")
      expect(api_resource.hashed_access_key).to eq(
        Digest::SHA512.hexdigest(valid_attributes[:access_key]))
    end
  end
end
