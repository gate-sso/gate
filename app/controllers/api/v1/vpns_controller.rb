class ::Api::V1::VpnsController < ::Api::V1::BaseController
  before_action :set_vpn, only: [:assign_group]

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

  def assign_group
    if current_user.admin?
      @vpn.groups.delete_all
      @vpn.groups << Group.where(id: params[:group_id]).first
      render json: { status: 'group assigned' }, status: :ok
    end
  end

  private

  def set_vpn
    @vpn = Vpn.find(params[:id])
  end

  def vpn_params
    params.require(:vpn).permit(:name, :host_name, :ip_address)
  end
end
