class GroupsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :set_group, only: %i[show edit update destroy
                                     add_user add_machine add_vpn add_admin
                                     remove_admin delete_user delete_vpn delete_machine]
  before_action :authenticate_user!

  prepend_before_action :setup_user if Rails.env.development?

  def index
    @groups = []
    @group_search = params[:group_search]
    if current_user.admin && @group_search.present?
      @groups = Group.where('name LIKE ?', "%#{@group_search}%")
    elsif current_user.group_admin? && !current_user.admin
      @groups = GroupAdmin.where(user_id: current_user.id).map(&:group)
    end
  end

  def create
    if current_user.admin?
      @group = Group.new(group_params)
      respond_to do |format|
        if @group.save
          format.html { redirect_to group_path(@group), notice: 'Group was successfully created.' }
          format.json { render status: :created, json: "#{@group.name}host created" }
        else
          format.html { redirect_to groups_path, notice: "Can't save '#{group_params[:name]}'" }
          format.json { render status: :error, json: "#{@group.name} not created" }
        end
      end
    else
      format.html { redirect_to groups_path, notice: "Can't save '#{group_params[:name]}'" }
      format.json { render status: :error, json: "#{@group.name} not created" }
    end
  end

  def new
    @group = Group.new
  end

  def show
    # This is set in before_action filter
    # @group = Group.find(params[:id])
    @vpns = Vpn.all.select { |vpn| vpn.groups.count.zero? }
    @users = User.where(active: true)
    @host_machines = HostMachine.all
  end

  def delete_machine
    @machine = HostMachine.find(params[:host_machine_id])
    if current_user.admin?
      @machine.groups.delete(@group)
    end

    redirect_to group_path @group
  end

  def delete_user
    if current_user.admin? || @group.admin?(current_user)
      @user = User.find(params[:user_id])

      if @user.email.split('@').first != @group.name
        @user.groups.delete(@group)
        @group.burst_host_cache
      end

    end
    redirect_to group_path(@group, anchor: 'group_members')
  end

  def add_user
    if current_user.admin? || @group.admin?(current_user)
      user = User.find(params[:user_id])
      @group.add_user(user.id) if user.present?
      @group.burst_host_cache
    end

    respond_to do |format|
      format.html do
        redirect_to group_path(@group, anchor: 'group_members')
      end
    end
  end

  def add_machine
    if current_user.admin?
      machine = HostMachine.find(params[:machine_id])
      machine.groups << @group if machine.present? && machine.groups.find_by_id(@group.id).blank?
      machine.save!
    end

    respond_to do |format|
      format.html do
        redirect_to group_path @group
      end
    end
  end

  def add_admin
    if current_user.admin?
      GroupAdmin.find_or_create_by(group_id: @group.id, user_id: params[:user_id])
    end

    respond_to do |format|
      format.html do
        redirect_to group_path @group
      end
    end
  end

  def remove_admin
    if current_user.admin?
      GroupAdmin.delete(params[:group_admin_id])
    end

    respond_to do |format|
      format.html do
        redirect_to group_path @group
      end
    end
  end

  def add_vpn
    if current_user.admin?
      VpnGroupAssociation.find_or_create_by(group_id: @group.id, vpn_id: params[:vpn_id])
    end

    respond_to do |format|
      format.html do
        redirect_to group_path @group
      end
    end
  end

  def delete_vpn
    return unless current_user.admin? || @group.group_admin.user == current_user

    VpnGroupAssociation.where(group_id: @group.id, vpn_id: params[:vpn_id]).destroy_all
    VpnGroupUserAssociation.where(group_id: @group.id, vpn_id: params[:vpn_id]).destroy_all

    respond_to do |format|
      format.html do
        redirect_to group_path @group
      end
    end
  end

  def add_group
    @user = User.find(params[:id])
    if current_user.admin?
      @group = Group.find(params[:group_id])
      @group.add_user(@user.id)
    end
    redirect_to user_path
  end

  def delete_group
    @user = User.find(params[:user_id])
    if current_user.admin?
      group = Group.find(params[:id])

      if @user.email.split('@').first != group.name
        @user.groups.delete(group)
      end

    end

    redirect_to user_path(@user)
  end

  def list
    @groups = []
    @group_search = params[:group_search]
    return unless @group_search.present?

    if current_user.admin?
      @groups = Group.where('name LIKE ?', "%#{@group_search}%")
    elsif current_user.group_admin?
      @groups = GroupAdmin.where(user_id: current_user.id).map(&:group)
    end
  end

  def search
    @groups = Group.
      where('name LIKE ?', "%#{params[:q]}%").
      order('name ASC').
      limit(20)
    data = @groups.map { |group| { id: group.id, name: group.name } }
    render json: data
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def group_params
    params.require(:group).permit(:name)
  end
end
