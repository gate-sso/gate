require 'rails_helper'
RSpec.feature 'Update Organisation', type: :feature do
  let!(:org) { create(:organisation) }
  let(:org_data) { attributes_for(:organisation) }
  let(:user) { create(:user) }
  scenario 'Create an organisation successfully' do
    sign_in(user)
    visit organisation_path(org)
    select Country.all.sample.name, from: 'organisation_country'
    %w(name website domain state address admin_email_address slug unit_name).each do |key|
      fill_in "organisation_#{key}", with: org_data[key.to_sym]
    end
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
