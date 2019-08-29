class ::Api::V1::BaseController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :authenticate_user_from_token!

  def authenticate_user_from_token!
    if get_token.nil? || !AccessToken.valid_token(get_token)
      raise_unauthorized
    end
  end

  protected

  def current_user
    access_token = AccessToken.find_token(get_token)
    access_token.user
  end

  private

  def get_token
    if params.key?(:access_token)
      params[:access_token]
    elsif params.key?(:token)
      params[:token]
    elsif request.headers.key?(:Authorization)
      request.headers[:Authorization].split(' ').last
    end
  end

  def raise_unauthorized
    head :unauthorized
  end
end
