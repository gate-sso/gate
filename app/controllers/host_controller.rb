class HostController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :authenticate_user!
  def add_host
    @user = User.find(params[:id])
    if current_user.admin?
      host = Host.new
      host.user = @user
      host.host_pattern = params[:host_pattern]
      host.save!

    end
    redirect_to user_path
  end

  def delete_host
    @user = User.find(params[:user_id])
    if current_user.admin?
      @host = Host.find(params[:id])
      @host.deleted_by = current_user.id
      @host.save!
      @host.destroy
    end

    redirect_to user_path(@user)
  end
end
