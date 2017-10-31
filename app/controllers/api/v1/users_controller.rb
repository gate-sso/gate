class ::Api::V1::UsersController < ApiController
  before_action :set_paper_trail_whodunnit
  before_filter :authenticate_user_from_token!
  def create
    user = user_params
    if User.add_temp_user user[:name], user[:email]
      render json: { status: "created"}, status: :ok
    else
      render json: { status: "error"}, status: :unprocessable_entity
    end
  end

  def user_params
    params.require(:user).permit(:name,:email)
  end
end
