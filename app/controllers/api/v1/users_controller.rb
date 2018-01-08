class ::Api::V1::UsersController < ApiController
  before_filter :authenticate_user_from_token!
  def create
    user = user_params
    if User.add_temp_user user[:name], user[:email]
      render json: { status: "created"}, status: :ok
    else
      render json: { status: "error"}, status: :unprocessable_entity
    end
  end

  def show
    render json: { user: User.where(email: params[:email]).first }, status: :ok
  end

  def user_params
    params.require(:user).permit(:name,:email)
  end
end
