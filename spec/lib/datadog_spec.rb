require 'rails_helper'

RSpec.describe Datadog do

  let(:org) { create(:organisation) }
  let(:app_name) { 'datadog' }

  describe 'initialize' do
    it 'initialize datadog client if already saved' do
      config = create(:saml_app_config, organisation: org)
      expect(DataDogClient).to receive(:new).with(
        config.config['app_key'], config.config['api_key']
      )
      Datadog.new(org.id)
    end
  end

  describe 'save_config' do
    let(:config) { build(:saml_app_config, organisation: org) }
    let(:saml_app) { Datadog.new(org.id) }

    it 'should update the configuration of the application' do
      saml_app.save_config(config.sso_url, config.config)
      expect(saml_app.config.config).to eq(config.config)
    end

    it 'should call the parent class to update url and initialize group for the app' do
      expect_any_instance_of(SamlApp).
        to receive(:save_config).with(
          config.sso_url,
          config.config
        )
      saml_app.save_config(config.sso_url, config.config)
    end
  end

  describe 'add_user' do
    let(:email) { Faker::Internet.email }
    let(:saml_app) { Datadog.new(org.id) }

    before do
      create(:saml_app_config, organisation: org)
    end

    it 'adds a user when a user doesn\'t exist' do
      allow_any_instance_of(DataDogClient).
        to receive(:get_user).and_return({})
      expect_any_instance_of(DataDogClient).to receive(:new_user)
      saml_app.add_user(email)
    end

    it 'activates a user when a user exists' do
      allow_any_instance_of(DataDogClient).
        to receive(:get_user).and_return(handle: email)
      expect_any_instance_of(DataDogClient).to receive(:activate_user)
      saml_app.add_user(email)
    end

    it 'calls the parent class to add user to a group for a valid response' do
      allow_any_instance_of(DataDogClient).
        to receive(:get_user).and_return(handle: email)
      allow_any_instance_of(DataDogClient).to receive(:activate_user).and_return(handle: email)
      expect_any_instance_of(SamlApp).to receive(:add_user).
        with(email)
      saml_app.add_user(email)
    end

    it 'doesn\'t call the parent class to add user to a group for a invalid response' do
      allow_any_instance_of(DataDogClient).
        to receive(:get_user).and_return(handle: email)
      allow_any_instance_of(DataDogClient).to receive(:activate_user).and_return({})
      expect_any_instance_of(SamlApp).not_to receive(:add_user).
        with(email)
      saml_app.add_user(email)
    end
  end

  describe 'remove_user' do
    let(:email) { Faker::Internet.email }
    let(:saml_app) { Datadog.new(org.id) }

    before do
      create(:saml_app_config, organisation: org)
    end

    it 'deactivates a user for a valid email address' do
      expect_any_instance_of(DataDogClient).
        to receive(:deactivate_user)
      saml_app.remove_user(email)
    end

    it 'call the parent class to remove user from group for valid email' do
      allow_any_instance_of(DataDogClient).
        to receive(:deactivate_user).and_return(handle: email)
      expect_any_instance_of(SamlApp).to receive(:remove_user)
      saml_app.remove_user(email)
    end

    it 'not call the parent class to remove user from group for valid email' do
      allow_any_instance_of(DataDogClient).
        to receive(:deactivate_user).and_return({})
      expect_any_instance_of(SamlApp).not_to receive(:remove_user)
      saml_app.remove_user(email)
    end
  end
end
