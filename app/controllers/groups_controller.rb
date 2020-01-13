class GroupsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :set_group, only: %i[show edit update destroy
                                     add_user add_machine add_vpn add_admin
                                     remove_admin delete_user delete_vpn delete_machine]
  before_action :authenticate_user!

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
    @group_users = User.
      select(%Q{
        users.id AS id,
        name,
        email,
        active,
        group_associations.created_at AS join_date,
        group_associations.expiration_date AS group_expiration_date
      }).
      joins('LEFT OUTER JOIN group_associations ON users.id = group_associations.user_id').
      where('group_associations.group_id = ?', @group.id)
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
        @group.remove_user @user
      end

    end
    redirect_to group_path(@group, anchor: 'group_members')
  end

  def add_user
    if current_user.admin? || @group.admin?(current_user)
      user = User.find(params[:user_id])
      begin
        expiration_date = expiration_date_param
      rescue ArgumentError
        return respond_to do |format|
          format.html { redirect_to group_path(@group), notice: 'Expiration date is wrong' }
        end
      end
      @group.add_user_with_expiration(user.id, expiration_date) if user.present?
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
    user_id = params[:id]
    if current_user.admin?
      begin
        expiration_date = expiration_date_param
      rescue ArgumentError
        response_message = 'Expiration date is wrong'
        return redirect_to user_path, notice: response_message
      end
      group = Group.find(params[:group_id])
      group.add_user_with_expiration(user_id, expiration_date)
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

  def expiration_date_param
    expiration_date = params[:expiration_date]
    return nil if expiration_date.nil? || expiration_date.empty?

    Date.parse(expiration_date, '%Y-%m-%d')
  end
end
