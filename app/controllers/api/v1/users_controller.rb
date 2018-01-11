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
    user = User.select("id, email, name, active, admin, public_key, user_login_id, home_dir, shell, uid, provider, product_name").where(email: params.require(:email)).first
    if user.present?
      render json: { user: user }, status: :ok
    else
      head :not_found
    end
  end

  def user_params
    params.require(:user).permit(:name,:email)
  end
end
