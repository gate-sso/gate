require 'rails_helper'


RSpec.describe ApiResourcesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # ApiResource. As you add validations to ApiResource, be sure to
  # adjust the attributes here as well.
  let(:user) { FactoryBot.create(:user, name: "foobar", admin: true, user_login_id: "foobar", email: "foobar@foobar.com")  }
  let(:group) { FactoryBot.create(:group, name: "foobar_group") }
  let(:valid_attributes) do
    {
      name: "sample_api",
      description: "sample_api_description",
      access_key: "xcz",
      user_id: user,
      group_id: group
    }
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
      get :index, params: {}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      api_resource = ApiResource.create! valid_attributes
      get :show, params: {:id => api_resource.to_param}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: {}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      api_resource = ApiResource.create! valid_attributes
      get :edit, params: {:id => api_resource.to_param}, session: valid_session
      expect(response).to be_success
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new ApiResource" do
        sign_in user

        expect {
          post :create, params: {:api_resource => valid_attributes}, session: valid_session
        }.to change(ApiResource, :count).by(1)
      end

      it "redirects to the created api_resource" do
        post :create, params: {:api_resource => valid_attributes}, session: valid_session
        expect(response).to redirect_to(api_resource_path(assigns[:api_resource]))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: {:api_resource => invalid_attributes}, session: valid_session
        expect(response).to be_success
      end
    end
  end

  describe 'PUT #update' do
    let(:new_attributes) { { name: 'new_name', access_key: 'xyz' } }
    context 'authenticated as owner' do
      it 'should updates the requested api_resource' do
        api_resource = ApiResource.create! valid_attributes
        api_resource.update(user: create(:user, admin: false))
        sign_in api_resource.user
        put :update, params: { id: api_resource.to_param, api_resource: new_attributes }
        api_resource.reload
        expect(api_resource.name).to eq('new_name')
      end
    end

    context 'authenticated as admin' do
      context 'with valid params' do
        it 'updates the requested api_resource' do
          api_resource = ApiResource.create! valid_attributes
          put :update, params: { id: api_resource.to_param, api_resource: new_attributes }
          api_resource.reload
          expect(api_resource.name).to eq('new_name')
        end

        it 'redirects to the api_resource' do
          api_resource = ApiResource.create! valid_attributes
          put :update, params: { id: api_resource.to_param, api_resource: valid_attributes }
          expect(response).to redirect_to(api_resources_url)
        end
      end

      context 'with invalid params' do
        it 'returns a success response (i.e. to display the "edit" template)' do
          api_resource = ApiResource.create! valid_attributes
          put :update, params: { id: api_resource.to_param, api_resource: invalid_attributes }
          expect(response).to be_success
        end
      end
    end

    context 'authenticated as non admin' do
      it 'should not update api resource' do
        non_admin = create(:user, admin: false)
        sign_in non_admin
        api_resource = ApiResource.create! valid_attributes
        put :update, params: { id: api_resource.to_param, api_resource: new_attributes }
        updated_api_resource = ApiResource.find(api_resource.to_param)
        expect(updated_api_resource.to_json).to eq(api_resource.to_json)
      end

      context 'html response' do
        it 'should return notice unauthorized access' do
          non_admin = create(:user, admin: false)
          sign_in non_admin
          api_resource = ApiResource.create! valid_attributes
          put :update, params: { id: api_resource.to_param, api_resource: new_attributes }
          expect(flash[:notice]).to eq('Unauthorized access')
        end
      end

      context 'json response' do
        it 'should return 401 http status' do
          non_admin = create(:user, admin: false)
          sign_in non_admin
          api_resource = ApiResource.create! valid_attributes
          put :update, params: {
            format: 'json',
            id: api_resource.to_param,
            api_resource: new_attributes,
          }
          expect(response).to have_http_status(401)
        end

        it 'should return status error' do
          non_admin = create(:user, admin: false)
          sign_in non_admin
          api_resource = ApiResource.create! valid_attributes
          put :update, params: {
            format: 'json',
            id: api_resource.to_param,
            api_resource: new_attributes,
          }
          expect(response.body).to eq({ status: 'error' }.to_json)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'authenticated as admin' do
      it 'destroys the requested api_resource' do
        api_resource = ApiResource.create! valid_attributes
        expect { delete :destroy, params: { id: api_resource.to_param } }.
          to change(ApiResource, :count).by(-1)
      end

      it 'redirects to the api_resources list' do
        api_resource = ApiResource.create! valid_attributes
        delete :destroy, params: { id: api_resource.to_param }
        expect(response).to redirect_to(api_resources_url)
      end

      it 'should flash notice success' do
        api_resource = ApiResource.create! valid_attributes
        delete :destroy, params: { id: api_resource.to_param }
        expect(flash[:notice]).to eq('Api resource was successfully destroyed.')
      end
    end

    context 'authenticated as non admin' do
      it 'should flash notice unauthorized access' do
        non_admin = create(:user, admin: false)
        sign_in non_admin
        api_resource = ApiResource.create! valid_attributes
        delete :destroy, params: { id: api_resource.to_param }
        expect(flash[:notice]).to eq('Unauthorized access')
      end

      context 'json response' do
        it 'should return 401 http status' do
          non_admin = create(:user, admin: false)
          sign_in non_admin
          api_resource = ApiResource.create! valid_attributes
          delete :destroy, params: { format: 'json', id: api_resource.to_param }
          expect(response).to have_http_status(401)
        end
      end
    end
  end

  describe 'Search for API Resources' do
    it "should return API Resources according to supplied search string" do
      api_resources = create_list(:api_resource, 3)
      get :search, params: { q: "API" }
      expect(JSON.parse(response.body)).to eq(api_resources.map{|m| {"id" => m.id, "name" => m.name}})
    end
  end

  describe 'GET #regenerate_access_key' do
    context 'authenticated as admin' do
      it 'should regenerates access_key of the requested api_resource' do
        api_resource = ApiResource.create! valid_attributes
        old_hashed_access_key = api_resource.hashed_access_key
        get :regenerate_access_key, params: { id: api_resource.to_param }
        api_resource.reload
        expect(api_resource.hashed_access_key).to_not eq old_hashed_access_key
      end

      it 'should redirects to the api_resource' do
        api_resource = ApiResource.create! valid_attributes
        get :regenerate_access_key, params: { id: api_resource.to_param }
        expect(response).to redirect_to(api_resource_path(api_resource.id))
      end
    end

    context 'authenticated as owner' do
      it 'should regenerates access_key of the requested api_resource' do
        api_resource = ApiResource.create! valid_attributes
        api_resource.update(user: create(:user, admin: false))
        sign_in api_resource.user
        old_hashed_access_key = api_resource.hashed_access_key
        get :regenerate_access_key, params: { id: api_resource.to_param }
        api_resource.reload
        expect(api_resource.hashed_access_key).to_not eq old_hashed_access_key
      end
    end

    context 'authenticated as non admin' do
      it 'should flash notice unauthorized access' do
        non_admin = create(:user, admin: false)
        sign_in non_admin
        api_resource = ApiResource.create! valid_attributes
        get :regenerate_access_key, params: { id: api_resource.to_param }
        expect(flash[:notice]).to eq('Unauthorized access')
      end

      context 'json response' do
        it 'should return 401 http status' do
          non_admin = create(:user, admin: false)
          sign_in non_admin
          api_resource = ApiResource.create! valid_attributes
          get :regenerate_access_key, params: { format: :json, id: api_resource.to_param }
          expect(response).to have_http_status(401)
        end
      end
    end
  end

  describe "Authenticate" do
    it "should not authenticate if a user is NOT a member of API group" do
      user = create :user
      access_token = create :access_token
      user.access_token = access_token
      user.save!
      user.reload
      group = create :group
      api_resource = ApiResource.create! valid_attributes
      api_resource.group = group
      api_resource.save!
      get :authenticate, params: { access_key: valid_attributes[:access_key], access_token: access_token.token }, session: valid_session
      expect(response).not_to be_success
      body = JSON.parse(response.body)
      expect(body["result"]).to eq 1
    end

    it "should authenticate if a user is member of API group" do
      user = create :user
      access_token = create :access_token
      user.access_token = access_token
      user.save!
      user.reload
      group = create :group
      api_resource = ApiResource.create! valid_attributes
      api_resource.group = group
      group.users << user
      api_resource.save!
      get :authenticate, params: { access_key: valid_attributes[:access_key], access_token: access_token.token }, session: valid_session
      expect(response).to be_success
      body = JSON.parse(response.body)
      expect(body["result"]).to eq 0

    end
  end
end
