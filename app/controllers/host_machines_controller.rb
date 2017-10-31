class HostMachinesController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :set_host_machine, only: [:show, :edit, :update, :destroy, :delete_group]
  prepend_before_filter :setup_user if Rails.env.development?
  def index
    @title = "Host"
    @host_machines = HostMachine.all
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
  end

  def delete_group
    group = Group.find(params[:group_id])
    @host_machine.groups.delete(group)
    @host_machine.save!
    redirect_to host_machine_path @host_machine
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
