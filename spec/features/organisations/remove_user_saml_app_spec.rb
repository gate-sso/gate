require 'rails_helper'
RSpec.feature 'Config Saml App', type: :feature do
  let(:user) { create(:user) }
  let(:users) { create_list(:user, 10) }
  let(:org) { create(:organisation) }

  before do
    sign_in(user)
  end

  scenario 'Remove user from group' do
    create(
      :saml_app_config,
      organisation: org,
      group: Group.new(name: "#{org.slug}_saml_datadog_users")
    )
    allow_any_instance_of(Group).to receive(:users).and_return(users)
    home_path = organisation_config_saml_app_path(
      organisation_id: org.id, app_name: 'datadog'
    )
    visit home_path
    page.find('#manage-users-tab').click
    expect_any_instance_of(Datadog).
      to receive(:remove_user).with(users.first.email)
    page.find("#saml_user_remove_#{users.first.id}").click
    expect(current_path).to eq(home_path)
  end
end
