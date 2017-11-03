class UsersController < ApplicationController

  before_filter :authenticate_user!, :except => [:user_id, :verify, :authenticate, :authenticate_cas, :authenticate_ms_chap, :authenticate_pam, :public_key] unless Rails.env.development?

  def index
    @user_search = params[:user_search]
    @users = []
    @users = User.where("name like ?", "%#{@user_search}%").take(20) if @user_search.present?
  end

  def show
    @user = User.where(id: params[:id]).first
    @groups = Group.all 
    render_404 if @user.blank?
    if @user.present? && ( current_user.admin? || current_user.id == @user.id)
      #hack add blank text to public_key
      @user.public_key = "Add public key" if @user.public_key.blank?
      respond_to do |format|
        format.html
      end
    end
  end

  def update

  end

  def create

  end

end
