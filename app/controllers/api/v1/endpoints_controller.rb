class ::Api::V1::EndpointsController < ::Api::V1::BaseController
  def create
    unless current_user.admin?
      return head :forbidden
    end

    endpoint = Endpoint.new(endpoint_param)
    if endpoint.save
      render json: {
        id: endpoint.id,
        path: endpoint.path,
        method: endpoint.method,
      }
    else
      render json: { status: endpoint.errors }, status: :unprocessable_entity
    end
  end

  def add_group
    endpoint = Endpoint.find(params[:id])
    group = Group.find_by(group_param)
    endpoint.groups << group
    render json: {}
  end

  private

  def group_param
    params.require(:group).permit(:id)
  end

  def endpoint_param
    params.require(:endpoint).permit(:path, :method)
  end
end
