class ::Api::V1::EndpointsController < ::Api::V1::BaseController
  def create
    endpoint = Endpoint.new(endpoint_param)
    endpoint.save!
    render json: {
      id: endpoint.id,
      path: endpoint.path,
      method: endpoint.method,
    }
  end

  private

  def endpoint_param
    params.require(:endpoint).permit(:path, :method)
  end
end
