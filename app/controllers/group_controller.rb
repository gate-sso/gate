class GroupController < ApplicationController
  before_filter :authenticate_user!

  def add_group    
    @user = User.find(params[:id])
    if current_user.admin?

      @group = Group.find(params[:group_id])
      @user.groups << @group if @user.groups.find_by_id(params[:group_id]).blank?
      @user.save! 
    end
    redirect_to user_path
  end

  def delete_group  
    @user = User.find(params[:user_id])
    if current_user.admin?
      group = Group.find(params[:id])
      @user.groups.delete(group)
    end

    redirect_to user_path(@user)
  end

  def list
    @groups = []
    @group_search = params[:group_search]
    if @group_search.present?
      @groups = Group.where("name LIKE ?", "%#{@group_search}%" ).take(5) 
    end
  end

  def show

  end
end
