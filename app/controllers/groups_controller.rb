class GroupsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :set_group, only: [:show, :edit, :update, :destroy, :add_user, :add_machine, :add_vpn, :add_admin, :remove_admin, :delete_user, :delete_vpn, :delete_machine]
  prepend_before_filter :setup_user if Rails.env.development?

  def index
    @groups = []
    @group_search = params[:group_search]
    if current_user.admin && @group_search.present?
        @groups = Group.where("name LIKE ?", "%#{@group_search}%" )
    elsif current_user.group_admin?
        @groups = GroupAdmin.where(user_id: current_user.id).map{ |ga| ga.group }
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
    #This is set in before_action filter
    #@group = Group.find(params[:id])
    @vpns = Vpn.all.select {|vpn| vpn.groups.count == 0}
    @users = User.all
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
      end

    end
    redirect_to group_path(@group, anchor: "group_members")
  end

  def add_user
    if current_user.admin? || @group.admin?(current_user)
      user = User.find(params[:user_id])
      user.groups << @group if user.present? and user.groups.find_by_id(@group.id).blank?
      user.save!

    end

    respond_to do |format|
      format.html do
        redirect_to group_path(@group, anchor: "group_members")
      end
    end
  end

  def add_machine
    if current_user.admin?
      machine = HostMachine.find(params[:machine_id])
      machine.groups << @group if machine.present? and machine.groups.find_by_id(@group.id).blank?
      machine.save!
    end

    respond_to do |format|
      format.html do
        redirect_to group_path @group
      end
    end
  end

  def add_admin
    if current_user.admin? or @group.admin?(current_user)
      GroupAdmin.find_or_create_by(group_id: @group.id, user_id: params[:user_id])
    end

    respond_to do |format|
      format.html do
        redirect_to group_path @group
      end
    end
  end

  def remove_admin
    if current_user.admin? or  @group.admin?(current_user)
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
    if current_user.admin? || @group.group_admin.user == current_user
      VpnGroupAssociation.where(group_id: @group.id, vpn_id: params[:vpn_id]).destroy_all
      VpnGroupUserAssociation.where(group_id: @group.id, vpn_id: params[:vpn_id]).destroy_all

      respond_to do |format|
        format.html do
          redirect_to group_path @group
        end
      end
    end
  end
  def add_group    
    @user = User.find(params[:id])
    if current_user.admin?

      @group = Group.find(params[:group_id])
      @user.groups << @group if @user.groups.find_by_id(params[:group_id]).blank?
      @user.save! 
      REDIS_CACHE.del(PASSWD_NAME_RESPONSE + @user.email.split('@').first)
      REDIS_CACHE.del(SHADOW_NAME_RESPONSE + @user.email.split('@').first)
      REDIS_CACHE.del(PASSWD_UID_RESPONSE + @user.uid.to_s)

      @user.groups.each do |group|
        REDIS_CACHE.del(GROUP_NAME_RESPONSE + group.name)
        REDIS_CACHE.del(GROUP_GID_RESPONSE + group.gid.to_s)
      end


      @response = Group.get_all_response.to_json
      REDIS_CACHE.set(GROUP_ALL_RESPONSE, @response)
      REDIS_CACHE.expire(GROUP_ALL_RESPONSE, REDIS_KEY_EXPIRY)
      @response = User.get_all_shadow_response.to_json
      REDIS_CACHE.set(SHADOW_ALL_RESPONSE, @response)
      REDIS_CACHE.expire(SHADOW_ALL_RESPONSE, REDIS_KEY_EXPIRY)
      @response = User.get_all_passwd_response.to_json
      REDIS_CACHE.set(PASSWD_ALL_RESPONSE, @response)
      REDIS_CACHE.expire(PASSWD_ALL_RESPONSE, REDIS_KEY_EXPIRY)


    end
    redirect_to user_path
  end

  def delete_group  
    @user = User.find(params[:user_id])
    if current_user.admin?
      group = Group.find(params[:id])

      if @user.email.split('@').first != group.name
        @user.groups.each do |user_group|
          REDIS_CACHE.del(GROUP_NAME_RESPONSE + user_group.name)
          REDIS_CACHE.del(GROUP_GID_RESPONSE + user_group.gid.to_s)
        end
        @user.groups.delete(group)
        REDIS_CACHE.del(PASSWD_NAME_RESPONSE + @user.email.split('@').first)
        REDIS_CACHE.del(SHADOW_NAME_RESPONSE + @user.email.split('@').first)
        REDIS_CACHE.del(PASSWD_UID_RESPONSE + @user.uid.to_s)

        @response = Group.get_all_response.to_json
        REDIS_CACHE.set(GROUP_ALL_RESPONSE, @response)
        REDIS_CACHE.expire(GROUP_ALL_RESPONSE, REDIS_KEY_EXPIRY)
        @response = User.get_all_shadow_response.to_json
        REDIS_CACHE.set(SHADOW_ALL_RESPONSE, @response)
        REDIS_CACHE.expire(SHADOW_ALL_RESPONSE, REDIS_KEY_EXPIRY)
        @response = User.get_all_passwd_response.to_json
        REDIS_CACHE.set(PASSWD_ALL_RESPONSE, @response)
        REDIS_CACHE.expire(PASSWD_ALL_RESPONSE, REDIS_KEY_EXPIRY)

      end

    end

    redirect_to user_path(@user)
  end

  def list
    @groups = []
    @group_search = params[:group_search]
    if @group_search.present?
      if current_user.admin?
        @groups = Group.where("name LIKE ?", "%#{@group_search}%" )
      elsif current_user.group_admin?
        @groups = GroupAdmin.where(user_id: current_user.id).map{ |ga| ga.group }
      end
    end
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
