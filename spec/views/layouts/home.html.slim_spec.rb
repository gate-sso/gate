require 'rails_helper'

RSpec.describe 'layouts/home', type: :view do
  it 'should renders google auth link when sign in type google' do
    cached_sign_in_type = Figaro.env.sign_in_type
    ENV['SIGN_IN_TYPE'] = 'google'

    render

    assert_select "a[href$='#{user_google_oauth2_omniauth_authorize_path}']"

    ENV['SIGN_IN_TYPE'] = cached_sign_in_type
  end

  it 'should not renders google auth link when sign in type not google' do
    cached_sign_in_type = Figaro.env.sign_in_type
    ENV['SIGN_IN_TYPE'] = 'not_google'

    render

    assert_select "a[href$='#{user_google_oauth2_omniauth_authorize_path}']", 0

    ENV['SIGN_IN_TYPE'] = cached_sign_in_type
  end

  it 'renders sign in form' do
    render

    assert_select 'form[action=?][method=?]', user_sign_in_path, 'post' do
      assert_select 'input#name[name=name]'
      assert_select 'input#email[name=email]'
    end
  end
end
