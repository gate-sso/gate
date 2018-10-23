require 'rails_helper'

RSpec.describe Datadog do

  let(:org) { create(:organisation) }
  let(:app_name) { 'datadog' }
  let(:user) { create(:user) }

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
    let(:config) { build(:saml_app_config, organisation: org) }
    let(:saml_app) { Datadog.new(org.id) }

    it 'update the url' do
      saml_app.save_config(config.sso_url, config.config)
      expect(saml_app.config.sso_url).to eq(config.sso_url)
    end

    it 'create a group if a group doesn\'t exist' do
      org_name = "#{org.slug}_saml_#{saml_app.app_name}_users"
      expect(Group).to receive(:find_or_create_by).
        with(name: org_name)
      saml_app.save_config(config.sso_url, config.config)
    end

    it 'creates a group name with slug_saml_app_name_users' do
      org_name = "#{org.slug}_saml_#{saml_app.app_name}_users"
      saml_app.save_config(config.sso_url, config.config)
      expect(saml_app.config.group.name).to eq(org_name)
    end
  end

  describe 'add_user' do
    let(:saml_app) { Datadog.new(org.id) }

    before do
      create(
        :saml_app_config,
        organisation: org,
        group: Group.new(name: "#{org.slug}_saml_datadog_users")
      )
      allow_any_instance_of(DataDogClient).
        to receive(:get_user).and_return(handle: user.email)
      allow_any_instance_of(DataDogClient).
        to receive(:activate_user).and_return(handle: user.email)
    end

    it 'add user to the group' do
      expect_any_instance_of(Group).
        to receive(:add_user).with(user.id)
      saml_app.add_user(user.email)
    end
  end

  describe 'remove_user' do
    let(:saml_app) { Datadog.new(org.id) }

    before do
      create(
        :saml_app_config,
        organisation: org,
        group: Group.new(name: "#{org.slug}_saml_datadog_users")
      )
      allow_any_instance_of(DataDogClient).
        to receive(:deactivate_user).and_return(handle: user.email)
    end

    it 'remove user from the group' do
      expect_any_instance_of(Group).
        to receive(:remove_user).with(user.id)
      saml_app.remove_user(user.email)
    end
  end
end
