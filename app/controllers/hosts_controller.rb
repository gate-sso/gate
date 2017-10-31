class HostsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_filter :authenticate_access_token!
  def create
    users_email_list = params[:users_list].split(',')

    users_email_list.each do |user_email|
      @user = User.find_active_user_by_email(user_email)
      next if @user.nil?
      host = Host.new
      host.user = @user
      host.host_pattern = params[:host_pattern]
      host.save!
    end

    head :created
  end
end

