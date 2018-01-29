class ::Api::V1::UsersController < ApiController
  # respond_to :json, only: [:show]
  def create
    user = user_params
    if User.add_temp_user user[:name], user[:email]
      render json: { status: "created"}, status: :ok
    else
      render json: { status: "error"}, status: :unprocessable_entity
    end
  end

  def show
    @user = current_user
    if @user.present?
      user_attrs = %w(
        email uid name active admin home_dir shell public_key user_login_id
        product_name
      )
      data = @user.attributes.select { |k,v| user_attrs.include?(k) }
      data["groups"] = @user.groups.map { |g| { "id" => g.gid, "name" => g.name } }
      render json: data
    else
      head :not_found
    end
  end

  def update
    attrs = params.select { |k,v| %w(public_key name product_name).include?(k) }
    @user = current_user
    render json: { success: @user.update_profile(attrs) }
  end

  def user_params
    params.require(:user).permit(:name, :email, :public_key, :product_name)
  end
end
