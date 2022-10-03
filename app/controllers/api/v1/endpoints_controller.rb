class ::Api::V1::EndpointsController < ::Api::V1::BaseController
  before_action :authorize_user

  def create
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
    endpoint = Endpoint.find_by(id: params[:id])
    if endpoint.nil?
      return head :not_found
    end

    group = Group.find_by(group_param)
    group_endpoint = GroupEndpoint.new(group: group, endpoint: endpoint)

    if group_endpoint.save
      render json: {}
    else
      head :unprocessable_entity
    end
  end

  private

  def authorize_user
    unless current_user.admin?
      head :forbidden
    end
  end

  def group_param
    params.require(:group).permit(:id)
  end

  def endpoint_param
    params.require(:endpoint).permit(:path, :method)
  end
end
