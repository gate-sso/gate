class ProfileController < ApplicationController
  require 'vpn/mobileconfig'

  before_action :set_paper_trail_whodunnit
  skip_before_action :verify_authenticity_token, if: Proc.new { |c| c.request.format == 'application/json' }
  before_action :authenticate_user!, except: %i[user_id verify authenticate authenticate_cas authenticate_ms_chap authenticate_pam public_key] unless Rails.env.development?
  prepend_before_action :setup_user if Rails.env.development?

  def regen_auth
    current_user.generate_two_factor_auth(true)
    redirect_to profile_path
  end

  def show
    @token_qr = nil
    unless current_user.provisioning_uri.blank?
      @token_qr = RQRCode::QRCode.new(current_user.provisioning_uri, size: 10, level: :h)
    end
  end

  def user_admin
    @users = []
    @groups = []
    if !current_user.admin?
      redirect_to profile_path
    end

    @user_search = params[:user_search]
    if @user_search.present?
      @users = User.where('name LIKE ? OR email LIKE ?', "%#{@user_search}%", "%#{@user_search}%").
        take(5)
      redirect_to profile_list_path(user_search: params[:user_search]) if @users.count.positive?
    end

    @group_search = params[:group_search]
    if @group_search.present?
      @groups = Group.where('name LIKE ?', "%#{@group_search}%").take(5)
      redirect_to group_list_path(group_search: params[:group_search]) if @groups.count.positive?
    end
  end

  def group_admin
    @users = []
    @groups = []
    if !current_user.admin? && !current_user.group_admin?
      redirect_to profile_path
    end

    @user_search = params[:user_search]
    if @user_search.present?
      @users = User.where('name LIKE ? OR email LIKE ?', "%#{@user_search}%", "%#{@user_search}%").
        take(5)
      redirect_to profile_list_path(user_search: params[:user_search]) if @users.count.positive?
    end

    @group_search = params[:group_search]
    if @group_search.present?
      @groups = Group.where('name LIKE ?', "%#{@group_search}%").take(5)
      redirect_to group_list_path(group_search: params[:group_search]) if @groups.count >= 0
    end
  end

  def user_id
    token = AccessToken.valid_token params[:token]
    response = 0
    if token
      user = User.get_user(params[:name])
      response = user.uid if user.present?
    end
    render plain: response
  end

  def download_vpn
    if !Pathname.new("/opt/vpnkeys/#{current_user.email}.tar.gz").exist?
      `cd /etc/openvpn/easy-rsa/ && bash /etc/openvpn/easy-rsa/gen-client-keys #{current_user.email}`
    else
      `cd /etc/openvpn/easy-rsa/ && bash /etc/openvpn/easy-rsa/gen-client-conf #{current_user.email}`
    end
    send_file(
      "/opt/vpnkeys/#{current_user.email}.tar.gz",
      type: 'application/zip',
      disposition: "attachment; filename=#{current_user.email}.tar.gz"
    )
  end

  def download_vpn_for_ios_and_mac
    mobileconfig = Mobileconfig.new
    vpns = Vpn.user_vpns current_user

    render plain: "you don't have access to any vpns" && return unless vpns.present?

    mobileconfig_data = mobileconfig.generate(vpns, current_user)

    send_data(
      mobileconfig_data,
      filename: "#{current_user.email}.mobileconfig",
      type: 'application/x-apple-aspen-config'
    )
  end

  def download_vpn_for_user
    render plain: 'Please download vpn config from your homepage'
  end

  def authenticate
    response = User.authenticate params
    if response
      render plain: 0
    else
      render plain: 1
    end
  end

  def authenticate_ms_chap
    response = User.ms_chap_auth params
    render plain: response
  end

  def authenticate_cas
    username = User.authenticate_cas request.env['HTTP_AUTHORIZATION']

    ## cas-5.2.x expects {"@c":".SimplePrincipal","id":"casuser","attributes":{}}
    response_map = {
      '@class': 'org.apereo.cas.authentication.principal.SimplePrincipal',
      'id': username,
      'attributes': { 'backend': 'gate-sso' },
    }

    if username.present?
      render json: response_map, status: :ok
    else
      response_map['attributes'] = nil
      render json: response_map, status: 401
    end
  end

  def authenticate_pam
    response = User.authenticate_pam params
    if response
      render plain: 0
    else
      render plain: 1
    end
  end

  def verify
    token = AccessToken.valid_token params[:token]
    if token
      response = User.verify params
      if response
        render plain: 0
      else
        render plain: 1
      end
    else
      render plain: 1
    end
  end

  def list
    @users = []
    @user_search = params[:user_search]
    if @user_search.present?
      @users = User.where('name LIKE ? OR email LIKE ?', "%#{@user_search}%", "%#{@user_search}%").
        take(5)
    end
  end

  def admin
    @users = []
    @groups = []
    if !current_user.admin?
      redirect_to profile_path
    end

    @user_search = params[:user_search]
    if @user_search.present?
      @users = User.where('name LIKE ? OR email LIKE ?', "%#{@user_search}%", "%#{@user_search}%").
        take(5)
      redirect_to profile_list_path(user_search: params[:user_search]) if @users.count.positive?
    end

    @group_search = params[:group_search]
    if @group_search.present?
      @groups = Group.where('name LIKE ?', "%#{@group_search}%").take(5)
      redirect_to group_list_path(group_search: params[:group_search]) if @groups.count.positive?
    end
  end

  def update
    if current_user.admin?
      @user = User.find(params[:id])
      @user.update(admin_active)
    end
    redirect_to user_path
  end

  def user_edit; end

  def public_key_update
    @user = User.where(id: params[:id]).first
    if current_user.admin? || current_user.id == @user.id
      @user.public_key = params[:public_key]
      @user.save!
    end
    redirect_to user_path
  end

  def public_key
    public_key = ''
    @user = User.get_user(params[:name])
    public_key = @user.public_key if @user.present?
    render plain: public_key
  end

  def user
    @group = Group.all
    @user = User.where(id: params[:id]).first

    if !current_user.admin? && current_user.id != @user.id
      redirect_to profile_path
    end
    render_404 if @user.blank?
    if @user.present?
      # hack add blank text to public_key
      @user.public_key = 'Add public key' if @user.public_key.blank?
      respond_to do |format|
        format.html
      end
    end
  end

  protected

  def admin_active
    params.require(:user).permit(:active, :admin)
  end
end
