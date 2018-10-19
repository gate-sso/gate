class OrganisationsController < ApplicationController
  before_action :load_org, only: %i(config_saml_app update show setup_saml)

  def index
    render :index, locals: { org_list: Organisation.all }
  end

  def new
    render :new, locals: { org: Organisation.new }
  end

  def config_saml_app
    saml_apps = Figaro.env.saml_apps.split(',').map(&:downcase)
    app_name = params[:app_name]
    if saml_apps.include?(app_name.downcase)
      render :config_saml_app, locals: { app_name: params[:app_name], org: @org }
    else
      redirect_to organisation_path(id: params[:organisation_id])
    end
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

  def organisation_params
    params.require(:organisation).permit(
      :name, :website, :domain, :country, :state, :address, :admin_email_address,
      :slug, :unit_name
    )
  end
end
