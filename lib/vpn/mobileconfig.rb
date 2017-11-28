require 'erb'
require 'vpn/namespace'

class Mobileconfig
  def generate (vpns, user)
    mobileconfig_template = File.read("#{Rails.root}/lib/vpn/mobileconfig.erb")

    vpn_hash = []
    vpns.each do |vpn|
      vpn_hash << {
        "payload_identifier" => "#{vpn.host_name.split('.').reverse.join('.')}.conf",
        "payload_uuid" => vpn.uuid,
        "user_defined_name" => vpn.name,
        "ikev2" => {
          "remote_address" => vpn.host_name,
          "remote_identifier" => vpn.host_name,
          "auth_name" => user.email.split('@').first
        },
        "dns" => {
          "server_addresses" => vpn.vpn_domain_name_servers.collect{ |vdns| vdns.server_address },
          "search_domains" => vpn.vpn_search_domains.collect{ |vsd| vsd.search_domain },
          "supplemental_match_domains" => vpn.vpn_supplemental_match_domains.collect{ |vsmd| vsmd.supplemental_match_domain },
        }
      }
    end

    confighash = {
      organization_name: ENV['GATE_ORGANIZATION_NAME'],
      reverse_vpn_url: ENV['GATE_URL'].split('.').reverse.join('.'),
      organization_static: ENV['GATE_ORGANIZATION_STATIC'],
      payload_content: vpn_hash
    }

    namespace = namespace.new(confighash)

    return erb.new(mobileconfig_template).result(namespace.get_binding)
  end
end
