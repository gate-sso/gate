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

  def add_properties
    render plain: "api only authorized for super admins" and return unless current_user.admin?

    @vpn = Vpn.find_by_ip_address(params[:vpn_ip_address])
    render plain: "Vpn not found" and return if @vpn.nil?

    vpn_domain_name_servers = params[:vpn_domain_name_servers]
    if vpn_domain_name_servers.present?
      @vpn.vpn_domain_name_servers.destroy_all

      vpn_domain_name_servers.each do |vpn_domain_name_server|
        @vpn_domain_name_server = VpnDomainNameServer.create(server_address: vpn_domain_name_server)
        @vpn.vpn_domain_name_servers << @vpn_domain_name_server
        @vpn.save!
      end
    end

    vpn_search_domains = params[:vpn_search_domains]
    if vpn_search_domains.present?
      @vpn.vpn_search_domains.destroy_all

      vpn_search_domains.each do |vpn_search_domain|
        @vpn_search_domain = VpnSearchDomain.create(search_domain: vpn_search_domain)
        @vpn.vpn_search_domains << @vpn_search_domain
        @vpn.save!
      end
    end

    vpn_supplemental_match_domains = params[:vpn_supplemental_match_domains]
    if vpn_supplemental_match_domains.present?
      @vpn.vpn_supplemental_match_domains.destroy_all

      vpn_supplemental_match_domains.each do |vpn_supplemental_match_domain|
        @vpn_supplemental_match_domain = VpnSupplementalMatchDomain.create(supplemental_match_domain: vpn_supplemental_match_domain)
        @vpn.vpn_supplemental_match_domains << @vpn_supplemental_match_domain
        @vpn.save!
      end
    end

    render plain: "Properties added to vpn"
  end
end
