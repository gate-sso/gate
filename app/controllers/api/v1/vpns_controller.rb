class ::Api::V1::VpnsController < ::Api::V1::BaseController
  def create
    if current_user.admin?
      @vpn = Vpn.new(vpn_params)
      if @vpn.save
        render json: { status: 'created' }, status: :ok
      else
        render json: { status: 'error' }, status: :unprocessable_entity
      end
    end
  end

  private

  def vpn_params
    params.require(:vpn).permit(:name, :host_name, :ip_address)
  end
end
