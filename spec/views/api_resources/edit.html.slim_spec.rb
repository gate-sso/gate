require 'rails_helper'

RSpec.describe "api_resources/edit", type: :view do
  before(:each) do
    @api_resource = assign(:api_resource, ApiResource.create!(
      :name => "MyString",
      :description => "MyString",
      :access_key => "MyString"
    ))
  end

  it "renders the edit api_resource form" do
    render

    assert_select "form[action=?][method=?]", api_resource_path(@api_resource), "post" do

      assert_select "input#api_resource_name[name=?]", "api_resource[name]"

      assert_select "input#api_resource_description[name=?]", "api_resource[description]"

      assert_select "input#api_resource_access_key[name=?]", "api_resource[access_key]"
    end
  end
end
