require 'rails_helper'
RSpec.feature 'Setup SAML', type: :feature do
  let!(:org) { create(:organisation) }
  let(:user) { create(:user) }
  scenario 'Should show a success message if SAML is setup' do
    sign_in(user)
    allow_any_instance_of(Organisation).to receive(:setup_saml_certs).and_return(true)
    visit organisation_setup_saml_path(org)
    expect(current_path).to eq(organisations_path)
    expect(page).to have_xpath(
      "//div[@id='organisation_form_success' and .='Successfully setup SAML Certificates']"
    )
  end
end
