require 'rails_helper'
RSpec.feature 'Update Organisation', type: :feature do
  let!(:org) { create(:organisation) }
  let(:org_data) { attributes_for(:organisation) }
  let(:user) { create(:user) }
  scenario 'Create an organisation successfully' do
    sign_in(user)
    visit organisation_path(org)
    fill_in 'organisation_name', with: org_data[:name]
    fill_in 'organisation_url', with: org_data[:url]
    fill_in 'organisation_email_domain', with: org[:email_domain]
    click_button('Update Organisation')
    expect(current_path).to eq(organisations_path)
    expect(page).to have_xpath(
      "//div[@id='organisation_form_success' and .='Successfully updated organisation']"
    )
  end
  scenario 'Display Errors on Creating Organisation' do
    sign_in(user)
    visit organisation_path(org)
    fill_in 'organisation_name', with: ''
    click_button('Update Organisation')
    expect(current_path).to eq(organisation_path(org))
    expect(page).to have_xpath(
      "//div[@id='organisation_form_errors']"
    )
  end
end
