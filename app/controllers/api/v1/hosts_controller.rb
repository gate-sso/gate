class ::Api::V1::HostsController < ApiController
  before_action :set_paper_trail_whodunnit
  skip_before_filter :authenticate_user_from_token!

  def add_users_list
    render plain: "api only authorized for super admins" and return unless current_user.admin?

    users_email_list = params[:users_list].split(',')

    users_email_list.each do |user_email|
      @user = User.find_active_user_by_email(user_email)
      next if @user.nil?
      host = Host.find_or_create_by(user: @user, host_pattern: params[:host_pattern])
    end

    render plain: "List of users given access"
  end
end
