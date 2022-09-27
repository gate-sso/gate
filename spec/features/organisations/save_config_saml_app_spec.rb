require 'rails_helper'
RSpec.feature 'Save Config Saml App', type: :feature do
  let(:org) { create(:organisation) }
  let(:user) { create(:user) }
  let(:app_name) { 'datadog' }

  before do
    sign_in(user)
  end

  scenario 'Load Present Configuration' do
    url = Faker::Internet.url
    saml_app = Datadog.new(org.id)
    app_key = Faker::Internet.password(min_length: 8)
    api_key = Faker::Internet.password(min_length: 8)
    saml_app.save_config(url, app_key: app_key, api_key: api_key)
    visit organisation_config_saml_app_path(
      organisation_id: org.id, app_name: app_name
    )
    page.find('#settings-tab').click
    expect(page.find_field('saml_app_config_sso_url').value).to eq(url)
    expect(page.find_field('config_app_key').value).to eq(app_key)
    expect(page.find_field('config_api_key').value).to eq(api_key)
  end

  scenario 'Load New Configuration If Not Saved' do
    visit organisation_config_saml_app_path(
      organisation_id: org.id, app_name: app_name
    )
    page.find('#settings-tab').click
    expect(page.find_field('saml_app_config_sso_url').value.blank?).to eq(true)
    expect(page.find_field('config_app_key').value.blank?).to eq(true)
    expect(page.find_field('config_api_key').value.blank?).to eq(true)
  end

  scenario 'Save Configuration' do
    url = Faker::Internet.url
    app_key = Faker::Internet.password(min_length: 8)
    api_key = Faker::Internet.password(min_length: 8)
    path = organisation_config_saml_app_path(
      organisation_id: org.id, app_name: app_name
    )
    visit path
    page.find('#settings-tab').click
    page.find_field('saml_app_config_sso_url').set(url)
    page.find_field('config_app_key').set(app_key)
    page.find_field('config_api_key').set(api_key)
    page.find('#new_saml_app_config').click
    expect(current_path).to eq(path)
  end
end
