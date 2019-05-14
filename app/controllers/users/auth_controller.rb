class Users::AuthController < ApplicationController
  before_action :set_paper_trail_whodunnit

  def sign_in
    redirect_to root_path
  end
end
