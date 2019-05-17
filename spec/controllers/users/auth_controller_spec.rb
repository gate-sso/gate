require 'rails_helper'

RSpec.describe Users::AuthController, type: :controller do
  let(:user) { FactoryBot.create(:user, name: 'foobar', email: 'foobar@foobar.com') }

  context 'sign in' do
    before(:each) do
      @cached_domain_env = ENV['GATE_HOSTED_DOMAINS']
      @cached_sign_in_type = ENV['SIGN_IN_TYPE']
      ENV['GATE_HOSTED_DOMAINS'] = 'foobar.com'
      ENV['SIGN_IN_TYPE'] = 'form'
    end

    after(:each) do
      ENV['GATE_HOSTED_DOMAINS'] = @cached_domain_env
      ENV['SIGN_IN_TYPE'] = @cached_sign_in_type
    end

    it 'should redirect to home when success' do
      post :log_in, params: { name: user.name, email: user.email }

      expect(response).to redirect_to(root_path)
    end

    it 'should produce error and unauthorized status when email domain is unsupported' do
      post :log_in, params: { name: user.name, email: 'foobar@notfoobar.com' }

      expect(response).to have_http_status(401)
      expect(response.body).to eq('Your domain is unauthorized')
    end

    it 'should generate two factor auth when success' do
      post :log_in, params: { name: user.name, email: user.email }

      user.reload
      expect(user.auth_key).not_to be_nil
    end

    it 'should set user session when success' do
      post :log_in, params: { name: user.name, email: user.email }

      expect(subject.current_user).to eq(user)
    end

    it 'should redirect to home when sign in type is not form' do
      ENV['SIGN_IN_TYPE'] = 'not_form'

      post :log_in, params: { name: user.name, email: user.email }

      expect(response).to redirect_to(root_path)
    end
  end
end
