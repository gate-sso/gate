class HostMachinesController < ApplicationController

  def show
    @host_machines = HostMachine.all
  end

  def create

  end
end
