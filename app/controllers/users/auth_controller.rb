class Users::AuthController < ApplicationController
  before_action :set_paper_trail_whodunnit

  def sign_in
    email = params.require(:email)

    unless User.valid_domain? email.split('@').last
      return render plain: 'Your domain is unauthorized', status: :unauthorized
    end

    redirect_to root_path
  end
end
