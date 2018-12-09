require 'rails_helper'
RSpec.feature 'Config Saml App', type: :feature do
  let(:user) { create(:user) }
  let(:users) { create_list(:user, 10) }
  let(:org) { create(:organisation) }

  before do
    sign_in(user)
  end

  scenario 'Display list of users for the saml app' do
    create(
      :saml_app_config,
      organisation: org,
      group: Group.new(name: "#{org.slug}_saml_datadog_users")
    )
    allow_any_instance_of(Group).to receive(:users).and_return(users)
    visit organisation_config_saml_app_path(
      organisation_id: org.id, app_name: 'datadog'
    )
    page.find('#manage-users-tab').click
    users.each do |user|
      expect(page).to have_xpath(
        "//td[.='#{user.email}']"
      )
      expect(page).to have_xpath(
        "//td/a[.='#{user.name}']"
      )
    end
  end

  scenario 'Display link for user profile' do
    create(
      :saml_app_config,
      organisation: org,
      group: Group.new(name: "#{org.slug}_saml_datadog_users")
    )
    allow_any_instance_of(Group).to receive(:users).and_return(users)
    visit organisation_config_saml_app_path(
      organisation_id: org.id, app_name: 'datadog'
    )
    page.find('#manage-users-tab').click
    users.each do |user|
      expect(page).to have_xpath(
        "//td/a[@href='#{user_path(id: user.id)}' and contains(string(), '#{user.name}')]"
      )
    end
  end

  scenario 'Display remove link for users' do
    create(
      :saml_app_config,
      organisation: org,
      group: Group.new(name: "#{org.slug}_saml_datadog_users")
    )
    allow_any_instance_of(Group).to receive(:users).and_return(users)
    visit organisation_config_saml_app_path(
      organisation_id: org.id, app_name: 'datadog'
    )
    page.find('#manage-users-tab').click
    users.each do |user|
      remove_path = organisation_remove_user_saml_app_path(
        organisation_id: org.id,
        app_name: 'datadog',
        email: user.email
      )
      expect(page).to have_xpath(
        "//td/a[.='Remove' and @href='#{remove_path}']"
      )
    end
  end
end
