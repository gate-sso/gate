class ApiResourcesController < ApplicationController
  before_action :set_api_resource, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :except => [:authenticate]

  # GET /api_resources
  # GET /api_resources.json
  def index
    @api_resources = ApiResource.where(user: current_user) if !current_user.admin
    @api_resources = ApiResource.all if current_user.admin
  end

  # GET /api_resources/1
  # GET /api_resources/1.json
  def show
  end

  def authenticate
    #this authenticates and tells whether users is able to access this api or not
    if (ApiResource.authenticate(params[:access_key], params[:access_token]))
      render  json: {result: 0}, status: :ok
    else
      render  json: {result: 1}, status: 401
    end
  end

  # GET /api_resources/new
  def new
    @api_resource = ApiResource.new
  end

  # GET /api_resources/1/edit
  def edit
  end

  # POST /api_resources
  # POST /api_resources.json
  def create
    @api_resource = ApiResource.new(api_resource_params)
    @api_resource.access_key = ROTP::Base32.random_base32
    @api_resource.user = current_user
    group = Group.create name: "#{@api_resource.name}_api_group"
    @api_resource.group = group
    group.add_admin current_user
    group.save!
    respond_to do |format|
      if @api_resource.save
        format.html { redirect_to api_resource_path(@api_resource.id), notice: 'Api resource was successfully created.', flash: {access_key: @api_resource.access_key} }
        format.json { render :show, status: :created, location: @api_resource }
      else
        format.html { render :new }
        format.json { render json: @api_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api_resources/1
  # PATCH/PUT /api_resources/1.json
  def update
    respond_to do |format|
      if @api_resource.update(api_resource_params)
        format.html { redirect_to api_resources_path, notice: 'Api resource was successfully updated.' }
        format.json { render :show, status: :ok, location: @api_resource }
      else
        format.html { render :edit }
        format.json { render json: @api_resource.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api_resources/1
  # DELETE /api_resources/1.json
  def destroy
    if current_user == @api_resource.user or current_user.admin
      @api_resource.group.destroy if @api_resource.group.present?
      @api_resource.destroy
    end
    respond_to do |format|
      format.html { redirect_to api_resources_url, notice: 'Api resource was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /api_resources/q=.json
  def search
    if params[:exact]
      @api_resources = ApiResource.where("name LIKE ?", "#{params[:q]}")
    else
      @api_resources = ApiResource.where("name LIKE ?", "%#{params[:q]}%")
    end
    @api_resources = @api_resources.order("name ASC").limit(20)
    data = @api_resources.map{ |group| {id: group.id, name: group.name} }
    render json: data
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_api_resource
    @api_resource = ApiResource.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def api_resource_params
    params.require(:api_resource).permit(:name, :access_key, :description, :user_id, :group_id)
  end
end
