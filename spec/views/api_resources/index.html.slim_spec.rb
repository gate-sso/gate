require 'rails_helper'

RSpec.describe "api_resources/index", type: :view do
  before(:each) do
    assign(:api_resources, [
      ApiResource.create!(
        :name => "Name",
        :description => "Description",
        :access_key => "Access Key"
      ),
      ApiResource.create!(
        :name => "Name2",
        :description => "Description",
        :access_key => "Access Key"
      )
    ])
  end

  it "renders a list of api_resources" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 1
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "********".to_s, :count => 2
  end
end
