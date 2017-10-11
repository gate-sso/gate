require 'rails_helper'

RSpec.describe HostsController do
  describe "POST #create" do
    context "for invalid or missing access tokens" do
      it 'unauthenticates the request' do
        post :create, token: 'invalid-token', format: :json

        expect(response).to have_http_status(401)
        expect(Host).not_to receive(:create)
      end
    end

    context 'for valid access token' do
      before(:each) do
        create(:group)
        AccessToken.destroy_all
        User.destroy_all
        Host.destroy_all
      end

      let(:access_token) { FactoryGirl.create :access_token }

      let(:user_one_email) { 'a@test.com' }
      let(:user_two_email) { 'b@test.com' }
      let(:users_list) { "#{user_one_email},#{user_two_email}" }

      let(:host_pattern) { 'p-kaizen-*' }

      subject(:hosts) { Host.where(host_pattern: host_pattern) }

      it 'adds host pattern for given list of users' do
        create(:user, email: "#{user_one_email}")
        create(:user, email: "#{user_two_email}")

        post :create,
          token: access_token.token,
          host_pattern: host_pattern,
          users_list: users_list,
          format: :json

        host_one, host_two = hosts
        expect(User.find(host_one.user_id).email).to eq(user_one_email)
        expect(User.find(host_two.user_id).email).to eq(user_two_email)
        expect(response).to have_http_status(201)
      end

      context 'when user is missing' do
        subject(:hosts) { Host.where(host_pattern: host_pattern) }

        it 'ignores entry for that user email' do
          post :create,
            token: access_token.token,
            host_pattern: host_pattern,
            users_list: 'missing@user.com',
            format: :json

          expect(hosts.empty?).to be_truthy
          expect(response).to have_http_status(201)
        end
      end

      context 'when user is inactive' do
        let(:inactive_user_email) { 'inactive@test.com' }

        subject(:hosts) { Host.where(host_pattern: host_pattern) }
        it 'ignores entry for that user' do
          create(:user, email: "#{inactive_user_email}", active: false)

          post :create,
            token: access_token.token,
            host_pattern: host_pattern,
            users_list: inactive_user_email,
            format: :json

          expect(User.where(email: inactive_user_email)).not_to be_empty
          expect(hosts.empty?).to be_truthy
          expect(response).to have_http_status(201)
        end
      end
    end
  end
end
