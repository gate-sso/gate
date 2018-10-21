require 'rails_helper'

RSpec.describe Datadog do

  let(:org) { create(:organisation) }
  let(:app_name) { 'datadog' }

  describe 'initialize' do
    it 'fetches configuration if already saved' do
      config = create(:saml_app_config, organisation: org)
      saml_app = Datadog.new(org.id)
      expect(saml_app.config).to eq(config)
    end

    it 'initializes configuration if not created' do
      saml_app = Datadog.new(org.id)
      expect(saml_app.config.persisted?).to eq(false)
    end
  end

  describe 'save_config' do
    let(:url) { Faker::Internet.url }
    let(:app_key) { Faker::Internet.password(8) }
    let(:api_key) { Faker::Internet.password(8) }
    it 'creates group if configuration isn\'t initialized' do
      saml_app = Datadog.new(org.id)
      saml_app.save_config(url, app_key: app_key, api_key: api_key)
      expect(saml_app.config.group.name).to eq('saml_datadog_users')
      expect(saml_app.config.persisted?).to eq(true)
      expect(saml_app.config.config['app_key']).to eq(app_key)
      expect(saml_app.config.config['api_key']).to eq(api_key)
      expect(saml_app.config.sso_url).to eq(url)
    end

    it 'saves the configuration for the application' do
      config = create(:saml_app_config, organisation: org)
      saml_app = Datadog.new(org.id)
      saml_app.save_config(url, app_key: app_key, api_key: api_key)
      expect(saml_app.config.id).to eq(config.id)
      expect(saml_app.config.config['app_key']).to eq(app_key)
      expect(saml_app.config.config['api_key']).to eq(api_key)
      expect(saml_app.config.sso_url).to eq(url)
    end
  end
end
