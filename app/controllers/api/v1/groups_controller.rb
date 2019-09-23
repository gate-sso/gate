class ::Api::V1::GroupsController < ::Api::V1::BaseController
  def create
    if current_user.admin?
      @group = Group.new(group_params)
      if @group.save
        render json: {
          id: @group.id,
          name: @group.name,
        }, status: :ok
      else
        is_taken = @group.errors.details[:name].select { |x| x[:error] == :taken }

        if !is_taken.blank?
          existing_group = Group.find_by(name: @group.name)
          render json: {
            status: 'group already exist',
            id: existing_group.id,
            name: existing_group.name,
          }, status: :unprocessable_entity
        else
          render json: {
            status: 'error',
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def add_user
    @group = Group.find_by(id: params[:id])
    return head :not_found unless @group.present?

    return raise_unauthorized unless current_user.admin? || @group.admin?(current_user)

    user = User.find_by(id: params[:user_id])
    return head :unprocessable_entity unless user.present?

    @group.add_user params[:user_id]
    head :no_content
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end
end
