class HostAccessGroupsController < ApplicationController
  def show

    @host_access_groups = HostAccessGroup.all

  end

  def create
    @host_access_group = HostAccessGroup.new(host_access_group_params)
    respond_to do |format|
      if @host_access_group.save
        format.html { redirect_to @host_access_group, notice: 'Access group was successfully created.' }
        format.json { render status: :created, json: "#{@host_access_group.name}host created" }
      else
        format.html { redirect_to host_access_group_path, notice: "Can't save '#{host_access_group_params[:name]}'" }
        format.json { render status: :error, json: "#{@host_access_group.name} not created" }
      end
    end


  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_host_access_group
    @host_access_group = host_machine.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def host_access_group_params
    params.require(:host_access_group).permit(:name)
  end


end
