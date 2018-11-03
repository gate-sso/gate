require 'rails_helper'

RSpec.describe DataDogClient do

  let(:email) { Faker::Internet.email }
  let(:org) { create(:organisation) }
  let(:app_key) { Faker::Internet.password(8) }
  let(:api_key) { Faker::Internet.password(8) }
  let(:base_url) { 'https://api.datadoghq.com/api/v1' }
  let(:client) { DataDogClient.new(app_key, api_key) }
  let(:auth_str) do
    "api_key=#{api_key}&application_key=#{app_key}"
  end
  let(:headers) do
    {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
    }
  end

  describe 'get_user' do
    it 'get user details for registered email address' do
      stub_request(:get, "#{base_url}/user/#{email}?#{auth_str}").
        to_return(status: 200, body: { user: { handle: email } }.to_json)
      expect(client.get_user(email)['handle']).to eq(email)
    end

    it 'get a blank hash for unregistered email address' do
      stub_request(:get, "#{base_url}/user/#{email}?#{auth_str}").
        with(headers: headers).
        to_return(status: 401)
      expect(client.get_user(email)).to eq({})
    end
  end

  describe 'new_user' do
    let(:params) { { handle: email }.to_json }
    it 'create a new user' do
      stub_request(:post, "#{base_url}/user?#{auth_str}").
        with(body: params, headers: headers).
        to_return(status: 200, body: { user: { handle: email } }.to_json)
      expect(client.new_user(email)['handle']).to eq(email)
    end

    it 'shouldn\'t create user if already exists' do
      stub_request(:post, "#{base_url}/user?#{auth_str}").
        with(body: params, headers: headers).
        to_return(status: 409)
      expect(client.new_user(email)).to eq({})
    end
  end

  describe 'activate_user' do
    let(:params) { { email: email, disabled: false }.to_json }
    it 'activates user and returns user object if email is found' do
      stub_request(:put, "#{base_url}/user/#{email}?#{auth_str}").
        with(body: params, headers: headers).
        to_return(status: 200, body: { user: { handle: email } }.to_json)
      expect(client.activate_user(email)['handle']).to eq(email)
    end

    it 'returns empty object if email is not found' do
      stub_request(:put, "#{base_url}/user/#{email}?#{auth_str}").
        with(body: params, headers: headers).
        to_return(status: 500)
      expect(client.activate_user(email)).to eq({})
    end
  end

  describe 'deactivate_user' do
    let(:params) { { email: email, disabled: true }.to_json }
    it 'deactivates user and returns user object if email is found' do
      stub_request(:put, "#{base_url}/user/#{email}?#{auth_str}").
        with(body: params, headers: headers).
        to_return(status: 200, body: { user: { handle: email } }.to_json)
      expect(client.deactivate_user(email)['handle']).to eq(email)
    end

    it 'returns empty object if email is not found' do
      stub_request(:put, "#{base_url}/user/#{email}?#{auth_str}").
        with(body: params, headers: headers).
        to_return(status: 500)
      expect(client.deactivate_user(email)).to eq({})
    end
  end
end
