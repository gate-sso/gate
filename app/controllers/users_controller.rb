class UsersController < ApplicationController
  before_action :set_paper_trail_whodunnit

  before_filter :authenticate_user!, :except => [:user_id, :verify, :authenticate, :authenticate_cas, :authenticate_ms_chap, :authenticate_pam, :public_key] unless Rails.env.development?

  def index
    @user_search = params[:user_search]
    @users = []
    @users = User.where("name like ?", "%#{@user_search}%").take(20) if @user_search.present?
  end

  def show
    @user = User.where(id: params[:id]).first
    @vpns = Vpn.user_vpns @user
    if current_user.admin? || current_user == @user
      @groups = Group.all
      render_404 if @user.blank?
      if @user.present? && ( current_user.admin? || current_user.id == @user.id)
        respond_to do |format|
          format.html
        end
      end
    end
  end

  def create
  end

  def update
    @user = User.find(params[:id])
    begin
      @user.update(product_name: product_name)
      response_message = "product name updated successfully!!"
    rescue ActionController::ParameterMissing => e
      response_message = "Params are missing"
    end

    form_response(response_message)
  end

  private
  def form_response(message)
    respond_to do |format|
      format.html { redirect_to user_path, notice: message }
    end
  end

  def product_name
    params.require(:product_name)
  end
end
