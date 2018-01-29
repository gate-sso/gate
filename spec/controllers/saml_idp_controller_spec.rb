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
    FactoryGirl.create(:group)
    user = FactoryGirl.create(:user, name: "foobar", user_login_id: "foobar", email: "foobar@foobar.com", admin: 1)
    sign_in user
    get :show
    hash = Hash.from_xml(response.body)
    expect(hash["EntityDescriptor"]["Organization"]["OrganizationName"]).to eq("Test")
    expect(hash["EntityDescriptor"]["Organization"]["OrganizationDisplayName"]).to eq("Test")
    expect(hash["EntityDescriptor"]["Organization"]["OrganizationURL"]).to eq("test-example.com")
  end
end
