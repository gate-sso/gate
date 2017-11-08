class ::Api::V1::VpnsController < ApiController
  before_action :set_paper_trail_whodunnit
  skip_before_filter :authenticate_user_from_token!

  def add_users_list
    render plain: "api only authorized for super admins" and return unless current_user.admin?

    @group = Group.find_by_name(params[:group_name])
    render plain: "Group not found" and return if @group.nil?

    @vpn = Vpn.find_by_ip_address(params[:vpn_ip_address])
    render plain: "Vpn not found" and return if @vpn.nil?

    render plain: "Vpn not authorized for group" and return unless @vpn.groups.include? @group

    users_email_list = params[:users_list].split(',')
    users_email_list.each do |user_email|
      @user = User.find_active_user_by_email(user_email)
      next if @user.nil?

      VpnGroupUserAssociation.find_or_create_by(vpn_id: @vpn.id, group_id: @group.id, user_id: @user.id)

      @user.save!
    end

    render plain: "List of users given access to vpn"
  end
end


