require 'rails_helper'
include Devise::TestHelpers

RSpec.describe SamlIdpController, type: :controller do

  it "should return proper xml for admin user" do
    SamlIdp.configure do |config|
      config.x509_certificate = File.open('/tmp/server.crt').read
      config.secret_key       = File.open('/tmp/server.key').read
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
