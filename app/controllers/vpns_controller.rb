class VpnsController < ApplicationController
  before_action :set_paper_trail_whodunnit
  before_action :authorize_user, except: [:create_group_associated_users, :show, :index, :user_associated_groups, :group_associated_users]
  before_action :set_vpn, only: [:show, :edit, :update, :destroy, \
                                 :user_associated_groups, :add_dns_server, :remove_dns_server, \
                                 :add_search_domain, :remove_search_domain, \
                                 :add_supplemental_match_domain, :remove_supplemental_match_domain, :assign_group]

  require 'securerandom'

  def index
    @vpns = Vpn.order(:name)
  end

  def update
    if current_user.admin?
      @vpn = Vpn.find(params[:id])
      if @vpn.update(vpn_params)
        redirect_to vpn_path(@vpn), notice: 'Vpn was successfully updated.' 
      end
    else
      redirect_to vpn_path(@vpn), notice: 'You can not update, not sufficient privileges.' 
    end
  end

  def create
    @vpn = Vpn.new(vpn_params)
    @vpn.uuid = SecureRandom.uuid
    respond_to do |format|
      if @vpn.save
        format.html { redirect_to vpns_path, notice: 'Vpn was successfully added.' }
        format.json { render status: :created, json: "#{@vpn.name}host created" }
      else
        format.html { redirect_to vpns_path, notice: "Can't save '#{vpn_params[:name]}'" }
        format.json { render status: :error, json: "#{@vpn.name} not created" }
      end
    end
  end

  def new
    @vpn = Vpn.new
  end

  def add_dns_server
    if current_user.admin?
      domain_name_server = VpnDomainNameServer.find_or_create_by(server_address: params[:server_address], vpn: @vpn) if  params[:server_address].present?
    end
    redirect_to vpn_path(@vpn, anchor: "dns_hosts")
  end

  def add_search_domain
    if current_user.admin?
      search_domain = VpnSearchDomain.find_or_create_by(search_domain: params[:search_domain], vpn: @vpn) if params[:search_domain].present?
    end
    redirect_to vpn_path(@vpn, anchor: "search_domains")
  end

  def add_supplemental_match_domain
    if current_user.admin?
      search_domain = VpnSupplementalMatchDomain.find_or_create_by(supplemental_match_domain: params[:supplemental_match_domain], vpn: @vpn) if  params[:supplemental_match_domain].present?
    end
    redirect_to vpn_path(@vpn, anchor: "match_domains")

  end

  def remove_dns_server
    if current_user.admin?
      vpn_domain_name_server = VpnDomainNameServer.delete(params[:vpn_domain_name_server_id])
    end
    redirect_to vpn_path(@vpn, anchor: "dns_hosts")
  end

  def remove_search_domain
    if current_user.admin?
      search_domain = VpnSearchDomain.delete(params[:vpn_search_domain_id])
    end
    redirect_to vpn_path(@vpn, anchor: "search_domains")

  end

  def remove_supplemental_match_domain
    if current_user.admin?
      search_domain = VpnSupplementalMatchDomain.delete(params[:vpn_supplemental_match_domain_id])
    end
    redirect_to vpn_path(@vpn, anchor: "match_domains")
  end

  def assign_group
    if current_user.admin?
      @vpn.groups.delete_all
      @vpn.groups << Group.where(id: params[:group_id]).first
    end
    redirect_to vpn_path(@vpn, anchor: "match_domains")
  end

  def show
    @vpn = Vpn.find(params[:id])
    @groups = Group.order(:name)
  end

  def user_associated_groups
    @groups_under_current_user = []
    @group_id = params[:group_id]
    @vpn_id = params[:id]
    if current_user.admin?
      @groups_under_current_user = Group.all
    else
      @vpn.groups.each do |vpn_group|
        if vpn_group.group_admin.try(:user) == current_user
          @groups_under_current_user << vpn_group
        end
      end
    end

    render "show"
  end

  def group_associated_users
    @group = Group.find(params[:group_id])
    if current_user.admin? || @group.group_admin.try(:user) == current_user
      @users = @group.users
      @vpn_group_user_associations = VpnGroupUserAssociation.where(vpn_id: params[:vpn_id], group_id: params[:group_id])
      @vpn_enabled_users = @vpn_group_user_associations.map { |r| r.user }

      @vpn_disabled_users = @users - @vpn_enabled_users

      @vpn_enabled_users = @vpn_enabled_users.sort_by{ |user| user.email}
      @vpn_disabled_users = @vpn_disabled_users.sort_by{ |user| user.email}
    end
    respond_to do |format|
      format.json { render status: :ok, json: { enabled: @vpn_enabled_users, disabled: @vpn_disabled_users } }
    end
  end

  def create_group_associated_users
    if current_user.admin? ||
        VpnGroupAssociation.find_by_vpn_id_and_group_id(params[:vpn_id].to_i, params[:group_id]).group.group_admin.user == current_user
      @users_selected = params[:users] || []
      @associations_made = []
      VpnGroupUserAssociation.where(vpn_id:params[:vpn_id].to_i, group_id: params[:group_id].to_i).each do |vpn_association|
        unless @users_selected.include? vpn_association.user.id
          vpn_association.destroy
        end
      end
      @users_selected.each do |user|
        @associations_made << VpnGroupUserAssociation.find_or_create_by(vpn_id: params[:vpn_id], group_id: params[:group_id], user_id: user.to_i)
      end

      respond_to do |format|
        format.json { render status: :ok, json: @associations_made }
      end
    else
      respond_to do |format|
        format.json { render status: :unauthorized, json: "not gonna happen" }
      end
    end
  end

  def destroy
    VpnGroupUserAssociation.where(vpn_id: params[:id]).destroy_all
    VpnGroupAssociation.where(vpn_id: params[:id]).destroy_all
    Vpn.destroy(params[:id])

    respond_to do |format|
      format.html { redirect_to vpns_path, notice: 'Vpn was successfully destroyed.' }
      format.json { render status: :ok, json: "vpn destroyed" }
    end
  end

  private
  def set_vpn
    @vpn = Vpn.find(params[:id])
  end

  def vpn_params
    params.require(:vpn).permit(:name, :host_name, :ip_address)
  end

  def authorize_user
    unless current_user.admin?
      redirect_to profile_path
    end
  end
end
