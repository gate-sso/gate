require 'rails_helper'

RSpec.describe "api_resources/new", type: :view do
  before(:each) do
    assign(:api_resource, ApiResource.new(
      :name => "MyString",
      :description => "MyString",
      :access_key => "MyString"
    ))
  end

  it "renders new api_resource form" do
    render

    assert_select "form[action=?][method=?]", api_resources_path, "post" do

      assert_select "input#api_resource_name[name=?]", "api_resource[name]"

      assert_select "input#api_resource_description[name=?]", "api_resource[description]"

      assert_select "input#api_resource_access_key[name=?]", "api_resource[access_key]"
    end
  end
end
