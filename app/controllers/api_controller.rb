class ApiController < ActionController::Base
  before_action :set_paper_trail_whodunnit
  protect_from_forgery with: :null_session
  before_filter :authenticate_user_from_token!

  def authenticate_user_from_token!
    auth_token = params[:access_token]
    authentication_error if !(Rails.application.secrets.secret_api_key == auth_token)
  end

  private
  def authentication_error
    head :unauthorized
  end
end
