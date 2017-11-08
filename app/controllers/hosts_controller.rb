class HostsController < ActionController::Base
  def create
    head :unauthorized if !(AccessToken.valid_token params[:token])
    users_email_list = params[:users_list].split(',')

    users_email_list.each do |user_email|
      @user = User.find_active_user_by_email(user_email)
      next if @user.nil?
      host = Host.find_or_create_by(user: @user, host_pattern: params[:host_pattern])
    end

    head :created
  end
end

