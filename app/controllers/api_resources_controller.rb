class ApiResourcesController < ApplicationController
  before_action :set_api_resource, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :except => [:authenticate] 

  # GET /api_resources
  # GET /api_resources.json
  def index
    @api_resources = ApiResource.all
  end

  # GET /api_resources/1
  # GET /api_resources/1.json
  def show
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

    respond_to do |format|
      if @api_resource.save
        format.html { redirect_to @api_resource, notice: 'Api resource was successfully created.' }
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
        format.html { redirect_to @api_resource, notice: 'Api resource was successfully updated.' }
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
    @api_resource.destroy
    respond_to do |format|
      format.html { redirect_to api_resources_url, notice: 'Api resource was successfully destroyed.' }
      format.json { head :no_content }
    end
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
