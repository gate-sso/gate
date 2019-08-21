class ::Api::V1::EndpointsController < ::Api::V1::BaseController
  def create
    endpoint = Endpoint.new(endpoint_param)
    if endpoint.save
      render json: {
        id: endpoint.id,
        path: endpoint.path,
        method: endpoint.method,
      }
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  private

  def endpoint_param
    params.require(:endpoint).permit(:path, :method)
  end
end
