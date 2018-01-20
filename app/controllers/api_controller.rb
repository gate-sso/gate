class ApiController < ActionController::Base
  protect_from_forgery with: :null_session
  before_filter :authenticate_user_from_token!

  def authenticate_user_from_token!
    user = User.by_token(get_token)
    if user.blank?
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
    user = User.by_token(get_token)
    raise_unauthorized if user.blank?
    return user
  end
end
