require 'rails_helper'

RSpec.describe 'layouts/home', type: :view do
  it 'renders google auth link' do
    render

    assert_select "a[href$='#{user_google_oauth2_omniauth_authorize_path}']"
  end

  it 'renders sign in form' do
    render

    assert_select 'form[action=?][method=?]', user_sign_in_path, 'post' do
      assert_select 'input#name[name=name]'
      assert_select 'input#email[name=email]'
    end
  end
end
