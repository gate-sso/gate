require 'rails_helper'
RSpec.feature 'Rengenerate Auth Token', type: :feature do
  let(:user) { create(:user) }
  let(:rotp_key) { ROTP::Base32.random_base32 }
  before(:each) do
    allow(ROTP::Base32).to receive(:random_base32).and_return(rotp_key)
  end
  scenario 'Create an organisation successfully' do
    sign_in user
    expect(user).to receive(:generate_two_factor_auth).with(true)
    visit regenerate_authentication_path
    expect(current_path).to eq(profile_path)
  end
end
