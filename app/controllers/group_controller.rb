class GroupController < ApplicationController
  before_filter :authenticate_user!
  SHADOW_NAME_RESPONSE = "SHADOW_NAME:"
  PASSWD_NAME_RESPONSE = "PASSWD_NAME:"
  PASSWD_UID_RESPONSE = "PASSWD_UID:"
  GROUP_NAME_RESPONSE = "GROUP_NAME:"
  GROUP_GID_RESPONSE = "GROUP_GID:"


  def add_group    
    @user = User.find(params[:id])
    if current_user.admin?

      @group = Group.find(params[:group_id])
      @user.groups << @group if @user.groups.find_by_id(params[:group_id]).blank?
      @user.save! 
      REDIS_CACHE.del(PASSWD_NAME_RESPONSE + @user.email.split('@'),first)
      REDIS_CACHE.del(SHADOW_NAME_RESPONSE + @user.email.split('@').first)
      REDIS_CACHE.del(PASSWD_UID_RESPONSE + @user.uid.to_s)

      @user.groups.each do |group|
        REDIS_CACHE.del(GROUP_NAME_RESPONSE + group.name)
        REDIS_CACHE.del(GROUP_GID_RESPONSE + group.gid.to_s)
      end
    end
    redirect_to user_path
  end

  def delete_group  
    @user = User.find(params[:user_id])
    if current_user.admin?
      group = Group.find(params[:id])
      @user.groups.each do |group|
        REDIS_CACHE.del(GROUP_NAME_RESPONSE + group.name)
        REDIS_CACHE.del(GROUP_GID_RESPONSE + group.gid.to_s)
      end
      @user.groups.delete(group)
      REDIS_CACHE.del(PASSWD_NAME_RESPONSE + @user.email.split('@'),first)
      REDIS_CACHE.del(SHADOW_NAME_RESPONSE + @user.email.split('@').first)
      REDIS_CACHE.del(PASSWD_UID_RESPONSE + @user.uid.to_s)

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
