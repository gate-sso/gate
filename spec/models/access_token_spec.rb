require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  let(:user) {
    FactoryBot.create(:user,
      name: "foobar",
      admin: true,
      user_login_id: "foobar",
      email: "foobar@foobar.com"
    )
  }

  before(:each) do
    @access_token = AccessToken.new
    @access_token.token = ROTP::Base32.random_base32
    @access_token.user = user
    @access_token.save!
  end

  describe "self.authenticate" do
    it "should return true if it finds matching token" do
      expect(AccessToken.valid_token(@access_token.token)).to eq true
    end
  end

  describe "hash_token! before_save" do
    it "should hash token and put it into hashed_token" do
      expect(@access_token.hashed_token).to eq(
        Digest::SHA512.hexdigest(@access_token.token))
    end
  end
end
