require 'rails_helper'
RSpec.feature 'Config Saml App', type: :feature do
  let(:org) { create(:organisation) }
  let(:user) { create(:user) }
  let(:saml_apps) { ENV['SAML_APPS'].split(',') }

  before do
    sign_in(user)
  end

  scenario 'Redirect to organisation detail if app not found' do
    visit organisation_config_saml_app_path(
      organisation_id: org.id, app_name: Faker::Lorem.word
    )
    expect(current_path).to eq(organisation_path(id: org.id))
  end

  scenario 'Redirect to list organisations if organisation not found' do
    visit organisation_config_saml_app_path(
      organisation_id: Faker::Number.number(1),
      app_name: Faker::Lorem.word
    )
    expect(current_path).to eq(organisations_path)
  end

  scenario 'View saml app configuration options' do
    saml_app = saml_apps.sample
    config_saml_app_path = organisation_config_saml_app_path(
      organisation_id: org.id,
      app_name: saml_app
    )
    visit config_saml_app_path
    expect(current_path).to eq(config_saml_app_path)
    expect(page).to have_xpath(
      "//a[@id='instruction-tab' and @href='#instruction' and .='Instructions']"
    )
    expect(page).to have_xpath(
      "//a[@id='settings-tab' and @href='#settings' and .='Settings']"
    )
    expect(page).to have_xpath(
      "//a[@id='manage-users-tab' and @href='#manage-users' and .='Manage Users']"
    )
  end

  scenario 'Instrutions for DataDog and Gate Configuration Steps, Manage Users on Gate' do
    saml_app = saml_apps.sample
    config_saml_app_path = organisation_config_saml_app_path(
      organisation_id: org.id,
      app_name: saml_app
    )
    visit config_saml_app_path
    expect(current_path).to eq(config_saml_app_path)
    expect(page).to have_xpath(
      "//h6[@id='configureDataDog' and .='Configuration Steps on #{saml_app.titleize}']"
    )
    expect(page).to have_xpath(
      "//h6[@id='configureGate' and .='Configuration Steps on Gate']"
    )
    expect(page).to have_xpath(
      "//h6[@id='manageUsersGate' and .='Manage Users on Gate']"
    )
  end
end
