class OrganisationsController < ApplicationController
  def index
    render :index, locals: { org_list: Organisation.all }
  end

  def new
    render :new, locals: { org: Organisation.new }
  end

  def create
    org = Organisation.setup(organisation_params.to_h || {})
    if org.errors.blank?
      flash[:success] = 'Successfully created organisation'
      redirect_to organisations_path
    else
      flash[:errors] = org.errors.full_messages
      redirect_to new_organisation_path
    end
  end

  def update
    org = load_org
    org.update_profile(organisation_params.to_h || {})
    if org.errors.blank?
      flash[:success] = 'Successfully updated organisation'
      redirect_to organisations_path
    else
      flash[:errors] = org.errors.full_messages
      redirect_to organisation_path(org)
    end
  end

  def show
    render :show, locals: { org: load_org }
  end

  private

  def load_org
    org = Organisation.where(params[:id]).first
    redirect_to organisations_path if org.blank?
    org
  end

  def organisation_params
    params.require(:organisation).permit(:name, :url, :email_domain)
  end
end
