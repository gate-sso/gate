class NssController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [ :add_host, :add_user_to_group ]

  def host
    token =  AccessToken.valid_token params[:token]
    @response = nil
    if token
      @response = HostMachine.get_group_response(params[:name]) if params[:name].present?
      render json: @response
      return
    end

    host_machine = HostMachine.find_by(access_key: params[:token])
    sysadmins = host_machine.sysadmins if host_machine.present?

    if sysadmins.present? && sysadmins.count > 0
      @response = Group.get_sysadmins_and_groups sysadmins
    end
    render json: @response
    return

  end

  def add_host
    token =  AccessToken.valid_token params[:token]
    if token
      @response = HostMachine.find_or_create_by(name: params[:name]) if params[:name].present?
      @group = Group.find_or_create_by(name: (params[:name] + "_host_group").downcase.squish ) if params[:group_name].present?
      @response.groups << @group  if @response.present? and @group.present? and @response.groups.find_by_id(@group.id).blank?
      @group = Group.find_or_create_by(name: params[:group_name] ) if params[:group_name].present?
      @response.groups << @group  if @response.present? and @group.present? and @response.groups.find_by_id(@group.id).blank?
      @response.save!
    end
    render json: @response
  end

  def group
    token = AccessToken.valid_token params[:token]
    @reponse = nil

    if token
      name = params[:name]
      if name.present?
        @response = Group.get_name_response(name).to_json
      end

      gid = params[:gid]
      if gid.present?
        @response = REDIS_CACHE.get(GROUP_GID_RESPONSE + gid)
        if @response.blank?
          @response = Group.get_gid_response(gid).to_json
          REDIS_CACHE.set(GROUP_GID_RESPONSE + gid, @response)
          REDIS_CACHE.expire(GROUP_GID_RESPONSE + gid, REDIS_KEY_EXPIRY)
        end
      end

      if name.blank? and gid.blank?
        @response = Group.get_all_response if @response.blank?
      end

      render json: @response
      return
    end

    host_machine = HostMachine.find_by(access_key: params[:token])
    sysadmins = host_machine.sysadmins if host_machine.present?


    if sysadmins.present? && sysadmins.count > 0
      @response = Group.get_sysadmins_and_groups sysadmins
    end

    render json: @response
  end

  def shadow
    token = AccessToken.valid_token params[:token]
    @response = nil

    if token
      name = params[:name]

      if name.present?
        @response = REDIS_CACHE.get(SHADOW_NAME_RESPONSE + name)
        if @response.blank?
          @response = User.get_shadow_name_response(name).to_json
          REDIS_CACHE.set(SHADOW_NAME_RESPONSE + name, @response)
          REDIS_CACHE.expire(SHADOW_NAME_RESPONSE + name, REDIS_KEY_EXPIRY)
        end
      else
        @response = REDIS_CACHE.get(SHADOW_ALL_RESPONSE)
        if @response.blank?
          @response = User.get_all_shadow_response.to_json
          REDIS_CACHE.set(SHADOW_ALL_RESPONSE, @response)
          REDIS_CACHE.expire(SHADOW_ALL_RESPONSE, REDIS_KEY_EXPIRY)
        end
      end
    end
    render json: @response
  end

  def passwd
    token = AccessToken.valid_token params[:token]
    @reponse = nil

    if token
      name = params[:name]

      if name.present?
        @response = REDIS_CACHE.get(PASSWD_NAME_RESPONSE + name)
        if @response.blank?
          @response = User.get_passwd_name_response(name).to_json
          REDIS_CACHE.set(PASSWD_NAME_RESPONSE + name, @response)
          REDIS_CACHE.expire(PASSWD_NAME_RESPONSE + name, REDIS_KEY_EXPIRY)
        end
      end
      uid = params[:uid]
      if uid.present?
        @response = REDIS_CACHE.get(PASSWD_UID_RESPONSE + uid)
        if @response.blank?
          @response = User.get_passwd_uid_response(uid).to_json
          REDIS_CACHE.set(PASSWD_UID_RESPONSE + uid, @response)
          REDIS_CACHE.expire(PASSWD_UID_RESPONSE + uid, REDIS_KEY_EXPIRY)
        end
      end

      if name.blank? and uid.blank?
        @response = REDIS_CACHE.get(PASSWD_ALL_RESPONSE)
        if @response.blank?
          @response = User.get_all_passwd_response.to_json
          REDIS_CACHE.set(PASSWD_ALL_RESPONSE, @response)
          REDIS_CACHE.expire(PASSWD_ALL_RESPONSE, REDIS_KEY_EXPIRY)
        end
      end
      render json: @response
      return
    end
    host_machine = HostMachine.find_by(access_key: params[:token])
    sysadmins = host_machine.sysadmins if host_machine.present?

    if sysadmins.present? && sysadmins.count > 0
      @response = User.get_sysadmins sysadmins
    end

    render json: @response


  end

  def groups_list
    token =  AccessToken.valid_token params[:token]
    if token
      user = User.get_user(params[:email].split("@").first)
      if user.blank?
        render json: { success: false }
      else
        groups = user.blank? ? [] : user.group_names_list
        render json: { success: true, groups: groups }
      end
    else
      render json: { success: false }
    end
  end
end
