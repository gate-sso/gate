require 'rails_helper'
include Devise::TestHelpers

RSpec.describe SamlIdpController, type: :controller do

  it "should return proper xml for admin user" do
    cert_helper  = CertificateHelper.new
    SamlIdp.configure do |config|
      config.x509_certificate = cert_helper.get_cert
      config.secret_key       = cert_helper.get_private_key
      config.organization_name  = "Test"
      config.organization_url   = "test-example.com"
    end
    FactoryBot.create(:group)
    user = FactoryBot.create(:user, name: "foobar", user_login_id: "foobar", email: "foobar@foobar.com", admin: 1)
    sign_in user

    allow(Figaro.env).to receive(:ENABLE_SAML).and_return(true)

    get :show

    hash = Hash.from_xml(response.body)
    expect(hash["EntityDescriptor"]["Organization"]["OrganizationName"]).to eq("Test")
    expect(hash["EntityDescriptor"]["Organization"]["OrganizationDisplayName"]).to eq("Test")
    expect(hash["EntityDescriptor"]["Organization"]["OrganizationURL"]).to eq("test-example.com")
  end

  describe "Service provider" do
    before(:each) do
      @user = build(:user)
      @user.access_token = build(:access_token)
      @user.save
      @token = @user.access_token.token
    end
    it "should create new service provider in db" do
      post :add_saml_sp, name: "test_sp", sso_url: "sso1", metadata_url: "metadata1", access_token: @token
      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body['name']).to eq("test_sp")
      expect(body['sso_url']).to eq("sso1")
      expect(body['metadata_url']).to eq("metadata1")
    end
    it "should create new service provider in db" do
      FactoryBot.create(:saml_service_provider, name: "test_sp", sso_url: "sso1", metadata_url: "metadata1")

      get :get_saml_sp, name: "test_sp", access_token: @token
      body = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(body['name']).to eq("test_sp")
      expect(body['sso_url']).to eq("sso1")
      expect(body['metadata_url']).to eq("metadata1")
    end
  end

end
