class ApiController < ActionController::Base
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

  protected

  def current_user
    AccessToken.find_by_token(request.headers[:Authorization]).user
  end
end
