require 'erb'
require 'vpn/namespace'
require 'openssl'

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
      organization_name: ENV['GATE_ORGANIZATION_NAME']+" IKEv2 VPN Configuration",
      reverse_vpn_url: ENV['GATE_URL'].split('.').reverse.join('.'),
      organization_static: ENV['GATE_ORGANIZATION_STATIC'],
      payload_content: vpn_hash
    }

    namespace = Namespace.new(confighash)

    mobileconfig_unsigned = ERB.new(mobileconfig_template).result(namespace.get_binding)

    return sign_mobileconfig(mobileconfig_unsigned)
  end

  private

  def sign_mobileconfig(mobileconfig)
    private_key = Base64.decode64(ENV['GATE_VPN_SSL_PVTKEY'])
    signing_cert = Base64.decode64(ENV['GATE_VPN_SSL_CERT'])
    cross_signed_cert = Base64.decode64(ENV['GATE_VPN_SSL_XSIGNED'])

    key = OpenSSL::PKey::RSA.new private_key
    cert = OpenSSL::X509::Certificate.new signing_cert
    cross_signed = OpenSSL::X509::Certificate.new cross_signed_cert

    return OpenSSL::PKCS7.sign(cert, key, mobileconfig, [cross_signed] ).to_der
  end
end
