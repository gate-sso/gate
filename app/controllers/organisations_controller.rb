class OrganisationsController < ApplicationController
  before_action :load_org, only: %i(config_saml_app update show setup_saml save_config_saml_app)
  before_action :validate_app_name, only: %i(config_saml_app save_config_saml_app)

  def index
    render :index, locals: { org_list: Organisation.all }
  end

  def new
    render :new, locals: { org: Organisation.new }
  end

  def config_saml_app
    app_name = params[:app_name]
    saml_app = app_name.titleize.constantize.new(@org.id)
    render :config_saml_app, locals: {
      org: @org,
      saml_config: saml_app.config,
      app_name: app_name,
    }
  end

  def save_config_saml_app
    app_name = params[:app_name]
    saml_app_config = params[:saml_app_config]
    saml_app = app_name.titleize.constantize.new(@org.id)
    saml_app.save_config(saml_app_config[:sso_url], params[:config])
    flash[:success] = 'Configuration saved successfully'
    redirect_to organisation_config_saml_app_path(
      app_name: app_name,
      organisation_id: @org.id
    )
  end

  def create
    org = Organisation.setup(organisation_params.to_h || {})
    if org.errors.blank?
      flash[:success] = 'Successfully created organisation'
      redirect_to organisations_path
    else
      flash[:errors] = org.errors.full_messages
      render :new, locals: { org: org }
    end
  end

  def update
    @org.update_profile(organisation_params.to_h || {})
    if @org.errors.blank?
      flash[:success] = 'Successfully updated organisation'
      redirect_to organisations_path
    else
      flash[:errors] = @org.errors.full_messages
      render :show, locals: { org: @org }
    end
  end

  def show
    render :show, locals: { org: @org }
  end

  def setup_saml
    if @org.saml_setup?
      flash[:errors] = 'SAML Certificates Already Setup'
    else
      @org.setup_saml_certs
      flash[:success] = 'Successfully setup SAML Certificates'
    end
    redirect_to organisations_path
  end

  private

  def load_org
    id = params[:id] || params[:organisation_id]
    @org = Organisation.where(id: id).first
    if @org.blank?
      redirect_to organisations_path
    end
  end

  def validate_app_name
    saml_apps = Figaro.env.saml_apps.split(',').map(&:downcase)
    unless saml_apps.include?(params[:app_name].downcase)
      redirect_to organisation_path(id: params[:organisation_id])
    end
  end

  def organisation_params
    params.require(:organisation).permit(
      :name, :website, :domain, :country, :state, :address, :admin_email_address,
      :slug, :unit_name
    )
  end
end
