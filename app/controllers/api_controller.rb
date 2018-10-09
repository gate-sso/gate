class ApiController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :authenticate_user_from_token!

  def authenticate_user_from_token!
    unless AccessToken.valid_token(get_token)
      raise_unauthorized
    end
  end

  private
  def get_token
    if params.key?(:access_token)
      return params[:access_token]
    elsif params.key?(:token)
      return params[:token]
    elsif request.headers.key?(:Authorization)
      return request.headers[:Authorization].split(' ').last
    end
  end

  def raise_unauthorized
    head :unauthorized
  end

  protected
  def current_user
    user = if params.key?("email")
      User.find_by_email(params["email"])
    elsif params.key?("uid")
      User.find_by_uid(params["uid"])
    elsif params.key?("username")
      User.find_by_user_login_id(params["username"])
    end
    raise_unauthorized if user.blank?
    return user
  end
end
