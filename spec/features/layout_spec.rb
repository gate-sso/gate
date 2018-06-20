require 'rails_helper'
RSpec.feature 'Layout', type: :feature do
  let(:user) { create(:user) }
  let(:group_admin) { create(:group_admin) }
  let(:admin) { create(:admin_user) }
  scenario 'Access to user links' do
    sign_in(user)
    visit profile_path
    links = {
      'APIs' => api_resources_path,
      'VPNs' => vpns_path,
      'API' => new_api_resource_path,
    }
    links.each do |link_text, link_href|
      expect(page).to have_xpath(
        "//div[@id='main-navigation']//a[@href='#{link_href}' and .='#{link_text}']"
      )
    end
  end
  scenario 'Access to group admin links' do
    sign_in(group_admin)
    visit profile_path
    links = {
      'APIs' => api_resources_path,
      'Groups' => groups_path,
      'VPNs' => vpns_path,
      'API' => new_api_resource_path,
    }
    links.each do |link_text, link_href|
      expect(page).to have_xpath(
        "//div[@id='main-navigation']//a[@href='#{link_href}' and .='#{link_text}']"
      )
    end
  end
  scenario 'Access to admin links' do
    sign_in(admin)
    visit root_path
    links = {
      'Users' => users_path,
      'Hosts' => host_machines_path,
      'Organisations' => organisations_path,
      'Groups' => groups_path,
      'APIs' => api_resources_path,
      'VPNs' => vpns_path,
      'API' => new_api_resource_path,
      'Group' => new_group_path,
      'VPN' => new_vpn_path,
      'Organisation' => new_organisation_path,
    }
    links.each do |link_text, link_href|
      expect(page).to have_xpath(
        "//div[@id='main-navigation']//a[@href='#{link_href}' and .='#{link_text}']"
      )
    end
  end
end
