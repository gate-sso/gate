class HostMachinesController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :set_host_machine, only: [:add_group, :show, :edit, :update, :destroy, :delete_group]
  prepend_before_filter :setup_user if Rails.env.development?
  before_filter :authenticate_user!
  def index
    @title = "Host"
    @host_machines = HostMachine.all
    @host_machines = []
    @host_machine_search = params[:host_machine_search]
    if @host_machine_search.present?
      if current_user.admin?
        @host_machines = HostMachine.where("name LIKE ?", "%#{@host_machine_search}%" )
      end
    end


  end

  def create
    @host_machine = HostMachine.new(host_machine_params)
    respond_to do |format|
      if @host_machine.save
        format.html { redirect_to host_machines_path, notice: 'Host was successfully created.' }
        format.json { render status: :created, json: "#{@host_machine.name}host created" }
      else
        format.html { redirect_to host_machines_path, notice: "Can't save '#{host_machine_params[:name]}'" }
        format.json { render status: :error, json: "#{@host_machine.name} not created" }
      end
    end
  end

  def show
    @machine = @host_machine
    @groups = Group.all
  end

  def add_group
    @machine = @host_machine
    if current_user.admin?
      group = Group.find(params[:group_id])
      @machine.groups << group if @machine.present? and @machine.groups.find_by_id(group.id).blank?
      @machine.save!
    end

    respond_to do |format|
      format.html do
        redirect_to host_machine_path @host_machine
      end
    end
  end

  def delete_group
    group = Group.find(params[:group_id])
    @host_machine.groups.delete(group)
    @host_machine.save!
    redirect_to host_machine_path @host_machine
  end

  def search
    @host_machines = HostMachine.
      where("name LIKE ?", "%#{params[:q]}%").
      order("name ASC").
      limit(20)
    data = @host_machines.map{ |host_machine| {id: host_machine.id, name: host_machine.name} }
    render json: data
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_host_machine
    @host_machine = HostMachine.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def host_machine_params
    params.require(:host_machine).permit(:name)
  end

end
