require 'rails_helper'

RSpec.describe 'layouts/home', type: :view do
  before(:each) do
    @cached_sign_in_type = ENV['SIGN_IN_TYPE']
  end

  after(:each) do
    ENV['SIGN_IN_TYPE'] = @cached_sign_in_type
  end

  it 'should renders google auth link when use default sign in type' do
    ENV['SIGN_IN_TYPE'] = ''

    render

    assert_select "a[href$='#{user_google_oauth2_omniauth_authorize_path}']"
  end

  it 'should not renders google auth link when sign in type form' do
    ENV['SIGN_IN_TYPE'] = 'form'

    render

    assert_select "a[href$='#{user_google_oauth2_omniauth_authorize_path}']", 0
  end

  it 'renders sign in form' do
    ENV['SIGN_IN_TYPE'] = 'form'

    render

    assert_select 'form[action=?][method=?]', user_sign_in_path, 'post' do
      assert_select 'input#name[name=name]'
      assert_select 'input#email[name=email]'
    end
  end

  it 'should not renders sign in form when sign in type is not form' do
    ENV['SIGN_IN_TYPE'] = 'not_form'

    render

    assert_select 'form[action=?][method=?]', user_sign_in_path, 'post', 0
  end
end
