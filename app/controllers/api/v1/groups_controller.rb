class ::Api::V1::GroupsController < ApiController
  before_action :set_paper_trail_whodunnit
  skip_before_filter :authenticate_user_from_token!

  def add_users_list
    render plain: "api only authorized for super admins" and return unless current_user.admin?

    @group = Group.find_by_name(params[:group_name])
    render plain: "Group not found" and return if @group.nil?

    users_email_list = params[:users_list].split(',')
    users_email_list.each do |user_email|
      @user = User.find_active_user_by_email(user_email)
      next if @user.nil?

      @user.groups << @group if @user.groups.find_by_id(@group.id).blank?
      @user.save!
    end

    render plain: "List of users added"
  end

  def add_vpns_list
    render plain: "api only authorized for super admins" and return unless current_user.admin?

    @group = Group.find_by_name(params[:group_name])
    render plain: "Group not found" and return if @group.nil?

    vpn_ip_address_list = params[:vpn_ip_address_list].split(',')
    vpn_ip_address_list.each do |vpn_ip_address|
      @vpn = Vpn.find_by_ip_address(vpn_ip_address)
      next if @vpn.nil?

      @vpn.groups << @group if @vpn.groups.find_by_id(@group.id).blank?
      @vpn.save!
    end

    render plain: "Group has access to list of vpns"
  end
end
