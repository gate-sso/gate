class HostMachinesController < ApplicationController
#  before_action :set_host_machine, only: [:show, :edit, :update, :destroy]
  prepend_before_filter :setup_user if Rails.env.development?
  def show
    @host_machines = HostMachine.all
  end

  def create
    @host_machine = HostMachine.new(host_machine_params)
    respond_to do |format|
      if @host_machine.save
      format.html { redirect_to @host_machine, notice: 'Host was successfully created.' }
      format.json { render status: :created, json: "#{@host_machine.name}host created" }
      else
        format.html { redirect_to host_machine_path, notice: "Can't save '#{host_machine_params[:name]}'" }
      format.json { render status: :error, json: "#{@host_machine.name} not created" }
      end
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
