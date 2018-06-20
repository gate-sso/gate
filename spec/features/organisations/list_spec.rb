require 'rails_helper'
RSpec.feature 'List Organisations', type: :feature do
  let!(:orgs) { create_list(:organisation, 5) }
  let(:user) { create(:user) }
  scenario 'Can create an organisation' do
    sign_in(user)
    visit organisations_path
    expect(page).to have_xpath("//a[@id='new_organisation_btn']")
  end
  scenario 'View list of organisations' do
    sign_in(user)
    visit organisations_path
    table_xpath = "//div[@id='organisation_list']/table"
    orgs.each do |org|
      expect(page).to have_xpath(
        "#{table_xpath}//td/a[@href='#{organisation_path(org)}' and .='#{org.name}']"
      )
      expect(page).to have_xpath(
        "#{table_xpath}//td/a[@href='#{org.url}' and .='#{org.url}']"
      )
      expect(page).to have_xpath(
        "#{table_xpath}//td[.='#{org.email_domain}']"
      )
    end
  end
  scenario 'Ability to see organsiation details' do
    sign_in(user)
    visit organisations_path
    table_xpath = "//div[@id='organisation_list']/table"
    orgs.each do |org|
      expect(page).to have_xpath(
        "#{table_xpath}//td/a[@href='#{organisation_path(org)}' and .='#{org.name}']"
      )
    end
  end
end
