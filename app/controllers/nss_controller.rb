class NssController < ApplicationController

  skip_before_filter :verify_authenticity_token, only: [ :add_host ]
  def host
    token =  AccessToken.valid_token params[:token]
    @response = nil
    if token
      @response = HostMachine.get_group_response(params[:name]) if params[:name].present?
    end
    render json: @response
  end

  def add_host
    token =  AccessToken.valid_token params[:token]
    if token
      @response = HostMachine.create(name: params[:name]) if params[:name].present?
    end
    render json: @response
      
  end

  def group
    token = AccessToken.valid_token params[:token]
    @reponse = nil

    if token
      name = params[:name]
      if name.present?
        @response = REDIS_CACHE.get(GROUP_NAME_RESPONSE + name)
        if @response.blank?
          @response = Group.get_name_response(name).to_json
          REDIS_CACHE.set(GROUP_NAME_RESPONSE + name, @response)
          REDIS_CACHE.expire(GROUP_NAME_RESPONSE + name, REDIS_KEY_EXPIRY)
        end
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
        @response = REDIS_CACHE.get(GROUP_ALL_RESPONSE)
        if @response.blank?
          @response = Group.get_all_response.to_json
          REDIS_CACHE.set(GROUP_ALL_RESPONSE, @response)
          REDIS_CACHE.expire(GROUP_ALL_RESPONSE, REDIS_KEY_EXPIRY)
        end
      end
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
    end
    render json: @response
  end
end
