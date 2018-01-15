require 'rails_helper'

RSpec.describe SamlController, type: :controller do

  it "should return proper xml" do
    get :show
    hash = Hash.from_xml(response.body)
    expect(hash["EntityDescriptor"]["Organization"]["OrganizationName"]).to eq('"Go-Jek"')
    expect(hash["EntityDescriptor"]["Organization"]["OrganizationDisplayName"]).to eq('"Go-Jek"')
    expect(hash["EntityDescriptor"]["Organization"]["OrganizationURL"]).to eq('"https://www.go-jek.com/"')
  end
end
