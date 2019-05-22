class ::Api::V1::UsersController < ::Api::V1::BaseController
  before_action :set_user, only: %i[show update]

  def create
    user = user_params
    if User.add_temp_user user[:name], user[:email]
      render json: { status: 'created' }, status: :ok
    else
      render json: { status: 'error' }, status: :unprocessable_entity
    end
  end

  def show
    if @user.present?
      user_attrs = %w(
        email uid name active admin home_dir shell public_key user_login_id
        product_name
      )
      data = @user.attributes.select { |k, _v| user_attrs.include?(k) }
      data['groups'] = @user.groups.map { |g| { 'id' => g.gid, 'name' => g.name } }
      render json: data
    else
      head :not_found
    end
  end

  def update
    render json: { success: @user.update_profile(user_params) }
  end

  private

  def set_user
    @user = if params.key?('email')
              User.find_by_email(params['email'])
            elsif params.key?('uid')
              User.find_by_uid(params['uid'])
            elsif params.key?('username')
              User.find_by_user_login_id(params['username'])
            end
  end

  def user_params
    if params.key?(:user)
      params.require(:user).permit(:name, :email, :public_key, :product_name)
    else
      params.permit(:name, :email, :public_key, :product_name)
    end
  end
end
