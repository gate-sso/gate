class NssController < ApplicationController

  def group
    @reponse = nil

    name = params[:name]
    @response = Group.get_name_response(name)if name.present?

    gid = params[:gid]
    @response = Group.get_gid_response(gid) if gid.present?

    @response = Group.get_all_response if name.blank? and gid.blank?

    render json: @response
  end

  def shadow
    @response = nil

    name = params[:name]
    @response = User.get_shadow_name_response(name) if name.present?

    @response = User.get_all_shadow_response if name.blank?

    render json: @response
  end

  def passwd
    @reponse = nil

    name = params[:name]
    @response = User.get_passwd_name_response(name)if name.present?

    uid = params[:uid]
    @response = User.get_passwd_uid_response(uid) if uid.present?
    
    @response = User.get_all_passwd_response if name.blank? and uid.blank?

    render json: @response
  end
end
