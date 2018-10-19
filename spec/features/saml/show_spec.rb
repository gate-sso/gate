require 'rails_helper'
RSpec.feature 'Config Saml App', type: :feature do
  let(:org) { create(:organisation) }
  let(:user) { create(:user) }
  let(:saml_apps) { Figaro.env.saml_apps.split(',') }
  let(:xml_content) { Nokogiri::XML::Builder.new { |xml| xml.foo_bar 'hello' }.to_xml }

  before do
    sign_in(user)
    allow(SamlIdp.metadata).to receive(:signed).and_return(xml_content)
  end

  scenario 'Show metadata when no download flag' do
    visit metadata_path(slug: org.slug, app: saml_apps.sample)
    expect(page.body).to eq(xml_content)
  end

  scenario 'Download metadata with download flag' do
    visit metadata_path(slug: org.slug, app: saml_apps.sample, download: true)
    expect(page.response_headers['Content-Type']).to eq('text/xml')
    expect(page.response_headers['Content-Disposition']).to include('metadata.xml')
  end
end
