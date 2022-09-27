class Users::AuthController < ApplicationController

  def log_in
    unless ENV['SIGN_IN_TYPE'] == 'form'
      return redirect_to root_path
    end

    email = params.require(:email)
    name = params.require(:name)

    unless User.valid_domain? email.split('@').last
      return render plain: 'Your domain is unauthorized', status: :unauthorized
    end

    user = User.create_user(name, email)
    user.generate_two_factor_auth
    sign_in_and_redirect user, event: :authentication
  end
end
