require 'rails_helper'
RSpec.feature 'Create User', type: :feature do
  let(:user) { create(:user, admin: true) }

  before(:each) do
    sign_in user
  end

  scenario 'Main Navigation should have link to create user' do
    visit new_user_path
    expect(page).to have_xpath("//div[@id='main-navigation']//a[@href='#{new_user_path}']")
  end

  scenario 'If admin view user creation form' do
    roles = Figaro.env.user_roles.split(',').map(&:titleize).insert(0, "Select A Role")
    domains = Figaro.env.gate_hosted_domains.split(',').insert(0, "Select A Domain")
    visit new_user_path
    expect(page.find_field('user_first_name').value.blank?).to eq(true)
    expect(page.find_field('user_last_name').value.blank?).to eq(true)
    expect(page.find_field('user_mobile').value.blank?).to eq(true)
    expect(page.find_field('user_alternate_email').value.blank?).to eq(true)
    expect(page).to have_select('user_user_role', options: roles)
    expect(page).to have_select('user_domain', options: domains)
    expect(page).to have_button('Create User')
  end

  scenario 'if not admin redirect to root path' do
    user.update_attribute(:admin, false)
    sign_in user
    visit new_user_path
    expect(current_path).to eq(profile_path)
  end

  scenario 'Show success message if required fields are present' do
    new_user = create(:user)
    domain = new_user.email.split('@').last
    expect(User).to receive(:add_user).with(
      new_user.first_name, new_user.last_name, new_user.user_role, domain
    ).and_return(new_user)
    visit new_user_path
    page.find_field('user_first_name').set(new_user.first_name)
    page.find_field('user_last_name').set(new_user.last_name)
    page.find_field('user_mobile').set(new_user.mobile)
    page.find_field('user_alternate_email').set(new_user.alternate_email)
    page.select(domain, from: 'user_domain')
    page.select(new_user.user_role.titleize, from: 'user_user_role')
    # page.find_field('user_user_role').set(new_user.user_role)
    # page.find_field('user_domain').set(domain)
    page.find_button('Create User').click
    expect(current_path).to eq(user_path(id: new_user.id))
    expect(page).to have_xpath(
      "//div[@class='alert alert-success'  and contains(string(), 'Successfully Created User')]"
    )
  end

  scenario 'Show error message if required fields are not present' do
    new_user = build(:user)
    domain = new_user.email.split('@').last
    expect(User).to receive(:add_user).with(
      new_user.first_name, new_user.last_name, new_user.user_role, domain
    ).and_return(new_user)
    new_user.errors.add(:first_name, 'Cannot be blank')
    visit new_user_path
    page.find_field('user_first_name').set(new_user.first_name)
    page.find_field('user_last_name').set(new_user.last_name)
    page.find_field('user_mobile').set(new_user.mobile)
    page.find_field('user_alternate_email').set(new_user.alternate_email)
    page.select(domain, from: 'user_domain')
    page.select(new_user.user_role.titleize, from: 'user_user_role')
    # page.find_field('user_user_role').set(new_user.user_role)
    # page.find_field('user_domain').set(domain)
    page.find_button('Create User').click
    expect(current_path).to eq(new_user_path)
    expect(page).to have_xpath(
      "//div[@class='alert alert-danger' and contains(string(), 'Issue Creating User')]"
    )
  end
end
