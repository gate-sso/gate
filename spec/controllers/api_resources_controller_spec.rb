require 'rails_helper'


RSpec.describe ApiResourcesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # ApiResource. As you add validations to ApiResource, be sure to
  # adjust the attributes here as well.
  let(:user) { FactoryBot.create(:user, name: "foobar", admin: true, user_login_id: "foobar", email: "foobar@foobar.com")  }
  let(:group) { FactoryBot.create(:group, name: "foobar_group") }
  let(:valid_attributes) do
    {name: "sample_api", description: "sample_api_description",access_key: "xcz" , user_id: user, group_id: group}
  end


  let(:invalid_attributes) {
    { name: "non sample api", description: 100}
  }


  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ApiResourcesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before(:each) do
    sign_in user
  end
  describe "GET #index" do
    it "returns a success response" do
      api_resource = ApiResource.create! valid_attributes
      get :index, {}, valid_session
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      api_resource = ApiResource.create! valid_attributes
      get :show, {:id => api_resource.to_param}, valid_session
      expect(response).to be_success
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, {}, valid_session
      expect(response).to be_success
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      api_resource = ApiResource.create! valid_attributes
      get :edit, {:id => api_resource.to_param}, valid_session
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new ApiResource" do
        sign_in user

        expect {
          post :create, {:api_resource => valid_attributes}, valid_session
        }.to change(ApiResource, :count).by(1)
      end

      it "redirects to the created api_resource" do
        post :create, {:api_resource => valid_attributes}, valid_session
        expect(response).to redirect_to(api_resources_url)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, {:api_resource => invalid_attributes}, valid_session
        expect(response).to be_success
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {name: "new_name", access_key: "xyz"}
      }

      it "updates the requested api_resource" do
        api_resource = ApiResource.create! valid_attributes
        put :update, {:id => api_resource.to_param, :api_resource => new_attributes}, valid_session
        api_resource.reload
        expect(api_resource.name).to eq("new_name")
      end

      it "redirects to the api_resource" do
        api_resource = ApiResource.create! valid_attributes
        put :update, {:id => api_resource.to_param, :api_resource => valid_attributes}, valid_session
        expect(response).to redirect_to(api_resources_url)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        api_resource = ApiResource.create! valid_attributes
        put :update, {:id => api_resource.to_param, :api_resource => invalid_attributes}, valid_session
        expect(response).to be_success
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested api_resource" do
      api_resource = ApiResource.create! valid_attributes
      expect {
        delete :destroy, {:id => api_resource.to_param}, valid_session
      }.to change(ApiResource, :count).by(-1)
    end

    it "redirects to the api_resources list" do
      api_resource = ApiResource.create! valid_attributes
      delete :destroy, {:id => api_resource.to_param}, valid_session
      expect(response).to redirect_to(api_resources_url)
    end
  end

  describe 'Search for API Resources' do
    it "should return API Resources according to supplied search string" do
      api_resources = create_list(:api_resource, 3)
      get :search, { q: "API" }
      expect(JSON.parse(response.body)).to eq(api_resources.map{|m| {"id" => m.id, "name" => m.name}})
    end
  end

  describe "Authenticate" do
    it "should not authenticate if a user is member of API group" do
      user = create :user
      access_token = create :access_token
      user.access_token = access_token
      user.save!
      user.reload
      access_token.reload
      group = create :group
      api_resource = ApiResource.create! valid_attributes
      api_resource.group = group
      api_resource.save!
      get :authenticate, { access_key: valid_attributes[:access_key], access_token: user.access_token.token }, valid_session
      expect(response).not_to be_success
      body = JSON.parse(response.body)
      expect(body["result"]).to eq 1
    end

    it "should not authenticate if a user is NOT a member of API group" do

      user = create :user
      access_token = create :access_token
      user.access_token = access_token
      user.save!
      user.reload
      access_token.reload
      group = create :group
      api_resource = ApiResource.create! valid_attributes
      api_resource.group = group
      group.users << user
      api_resource.save!
      get :authenticate, { access_key: valid_attributes[:access_key], access_token: user.access_token.token }, valid_session
      expect(response).to be_success
      body = JSON.parse(response.body)
      expect(body["result"]).to eq 0

    end
  end

end
