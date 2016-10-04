class GroupsController < ApplicationController
  def index

    @groups = Group.all

  end

  def create
    @group = Group.new(group_params)
     respond_to do |format|
      if @group.save
      format.html { redirect_to groups_path, notice: 'Group was successfully created.' }
      format.json { render status: :created, json: "#{@group.name}host created" }
      else
        format.html { redirect_to groups_path, notice: "Can't save '#{group_params[:name]}'" }
      format.json { render status: :error, json: "#{@group.name} not created" }
      end
    end



  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = group.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def group_params
    params.require(:group).permit(:name)
  end



end
