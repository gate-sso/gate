class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  def setup_user
    current_user = User.where(email: "dev@a.c").first
    sign_in(current_user)
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end

  def authenticate_access_token!
    unless AccessToken.valid_token(params[:token])
      render json: {
        success: false,
        errors: ['Unauthorized']
      }, status: :unauthorized
    end
  end
end
