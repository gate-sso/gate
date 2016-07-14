class ProfileController < ApplicationController
  before_filter :authenticate_user!, :except => [:authenticate, :authenticate_pam] unless Rails.env.development?
  prepend_before_filter :setup_user if Rails.env.development?

  def show

  end

  def download_vpn
    if !Pathname.new("/opt/vpnkeys/#{current_user.email}.tar.gz").exist?
      `cd /etc/openvpn/easy-rsa/ && bash /etc/openvpn/easy-rsa/gen-client-keys #{current_user.email}`
    end
    send_file ("/opt/vpnkeys/#{current_user.email}.tar.gz")
  end

  def authenticate
    response = User.authenticate params
    if response
      render text: 0
    else
      render text: 1
    end
  end

  def authenticate_pam
    response = User.authenticate_pam params
    if response
      render text: 0
    else
      render text: 1
    end
  end

  def list
    @users = []
    @user_search = params[:user_search]
    if @user_search.present?
      @users = User.where("name LIKE ?", "%#{@user_search}%" ).take(5)
    end
  end

  def admin
    @users = []
    @groups = []
    if current_user.admin?
      @user_search = params[:user_search]
      if @user_search.present?
        @users = User.where("name LIKE ?", "%#{@user_search}%" ).take(5)
        redirect_to profile_list_path(user_search: params[:user_search]) if @users.count > 0
      end

      @group_search = params[:group_search]
      if @group_search.present?
        @groups = Group.where("name LIKE ?", "%#{@group_search}%" ).take(5) 
        redirect_to group_list_path(group_search: params[:group_search]) if @groups.count > 0
      end
    else
      redirect_to profile_path
    end
  end

  def update
    if current_user.admin?
      user_params = params[:user]
      @user = User.find(params[:id])
      @user.update(admin_active)
    end
    redirect_to user_path
  end

  def user_edit

  end

  def public_key_update
    @user = User.where(id: params[:id]).first
    if ( current_user.admin? || current_user.id == @user.id)
      @user.public_key = params[:public_key]
      @user.save!
    end
    redirect_to user_path
  end

  def user
    @group = Group.all
    @user = User.where(id: params[:id]).first
    if ( current_user.admin? || current_user.id == @user.id)
      render_404 if @user.blank?
      if @user.present?
        respond_to do |format|
          format.html
        end
      end
    else
      redirect_to profile_path
    end
  end

  protected
  def admin_active
    params.require(:user).permit(:active, :admin)
  end
end
