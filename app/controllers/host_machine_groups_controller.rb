class HostMachineGroupsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  def show
    @host_machines = HostMachine.all
  end

  def create
    @host_machine = HostMachine.new(host_machine_params)
    respond_to do |format|
      @host_machine.save
      format.html { redirect_to :show, notice: 'host_machine was successfully created.' }
      format.json { render status: :created, json: "#{@host_machine.name}host created" }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_host_machine
    @host_machine = host_machine.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def host_machine_params
    params.require(:host_machine).permit(:name)
  end
end
