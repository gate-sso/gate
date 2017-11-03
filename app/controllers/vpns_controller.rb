class VpnsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :set_vpn, only: [:show, :edit, :update, :destroy]

  def index
    @vpns = Vpn.all
  end

  def create
    puts params
    puts vpn_params

    @vpn = Vpn.new(vpn_params)
    respond_to do |format|
      if @vpn.save
        format.html { redirect_to vpns_path, notice: 'Vpn was successfully added.' }
        format.json { render status: :created, json: "#{@vpn.name}host created" }
      else
        format.html { redirect_to vpns_path, notice: "Can't save '#{vpn_params[:name]}'" }
        format.json { render status: :error, json: "#{@vpn.name} not created" }
      end
    end
  end

  def new
    @vpn = Vpn.new
  end

  def show
    @groups_under_current_user = []
    if current_user.admin?
      @groups_under_current_user = Group.all
    else
      @vpn.groups.each do |vpn_group|
        if vpn_group.group_admin.user == current_user
          @groups_under_current_user << vpn_group
        end
      end
    end
  end

  def group_associated_users
    @group = Group.find(params[:group_id])
    @users = @group.users
    @vpn_group_user_associations = VpnGroupUserAssociation.where(vpn_id: params[:vpn_id], group_id: params[:group_id])
    @vpn_enabled_users = @vpn_group_user_associations.map { |r| r.user }

    @vpn_disabled_users = @users - @vpn_enabled_users
    respond_to do |format|
      format.json { render status: :ok, json: { enabled: @vpn_enabled_users, disabled: @vpn_disabled_users } }
    end
  end

  def create_group_associated_users
    if current_user.admin? ||
        VpnGroupAssociation.find_by_vpn_id_and_group_id(params[:vpn_id].to_i, params[:group_id]).group.group_admin.user == current_user
      @associations_made = []
      VpnGroupUserAssociation.where(vpn_id: params[:vpn_id].to_i, group_id: params[:group_id].to_i).destroy_all
      params[:users].each do |user|
        @associations_made << VpnGroupUserAssociation.create(vpn_id: params[:vpn_id], group_id: params[:group_id], user_id: user.to_i)
      end
      respond_to do |format|
        format.json { render status: :ok, json: @associations_made }
      end
    else
      respond_to do |format|
        format.json { render status: :unauthorized, json: "not gonna happen" }
      end
    end
  end

  private
  def set_vpn
    @vpn = Vpn.find(params[:id])
  end

  def vpn_params
    params.require(:vpn).permit(:name, :host_name, :url, :ip_address)
  end
end
