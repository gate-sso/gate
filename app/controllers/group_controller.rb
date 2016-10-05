class GroupController < ApplicationController
  before_filter :authenticate_user!
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
        @user.groups.each do |group|
          REDIS_CACHE.del(GROUP_NAME_RESPONSE + group.name)
          REDIS_CACHE.del(GROUP_GID_RESPONSE + group.gid.to_s)
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
      @groups = Group.where("name LIKE ?", "%#{@group_search}%" ).take(5) 
    end
  end

  def show

    @group = Group.find(params[:id])

  end
end
