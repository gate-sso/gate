class Users::AuthController < ApplicationController
  before_action :set_paper_trail_whodunnit

  def sign_in
    email = params.require(:email)
    name = params.require(:name)

    unless User.valid_domain? email.split('@').last
      return render plain: 'Your domain is unauthorized', status: :unauthorized
    end

    user = User.create_user(name, email)
    user.generate_two_factor_auth
    redirect_to root_path
  end
end
