require 'rails_helper'

RSpec.describe 'layouts/home', type: :view do
  it 'renders google auth link' do
    render

    assert_select "a[href$='#{user_google_oauth2_omniauth_authorize_path}']"
  end
end
