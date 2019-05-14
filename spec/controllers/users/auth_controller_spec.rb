require 'rails_helper'

RSpec.describe Users::AuthController, type: :controller do
  let(:user) { FactoryBot.create(:user, name: 'foobar', email: 'foobar@foobar.com') }

  context 'sign in' do
    it 'should redirect to home when success' do
      post :sign_in, params: { name: user.name, email: user.email }

      expect(response).to redirect_to(root_path)
    end
  end
end
