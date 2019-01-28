class ::Api::V1::GroupsController < ::Api::V1::BaseController
  def create
    if current_user.admin?
      @group = Group.new(group_params)
      if @group.save
        render json: { status: 'created' }, status: :ok
      else
        render json: { status: 'error' }, status: :unprocessable_entity
      end
    end
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end
end
