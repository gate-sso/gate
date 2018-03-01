require 'rails_helper'

RSpec.describe "api_resources/show", type: :view do
  before(:each) do
    @api_resource = assign(:api_resource, ApiResource.create!(
      :name => "Name",
      :description => "Description",
      :access_key => "Access Key"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Description/)
    expect(rendered).to match(/Access Key/)
  end
end
