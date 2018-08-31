class SamlIdpController < SamlIdp::IdpController
  layout false
  before_action :setup_saml_configuration

  private

  def idp_authenticate(email, password)
    valid_user = User.find_and_check_user(email, password)
    valid_user ? User.get_user(email) : nil
  end

  def idp_make_saml_response(found_user)
    encode_response found_user
  end

  def idp_logout
    # user = User.by_email(saml_request.name_id)
    # user.logout
  end

  def setup_saml_configuration
    slug = params[:slug]
    org = Organisation.find_by_slug(slug)
    saml_url = "#{Figaro.env.gate_url}#{slug}/saml"
    SamlIdp.configure do |config|
      config.x509_certificate = org.cert_key
      config.secret_key = org.cert_private_key
      config.organization_name = org.name
      config.organization_url = org.website
      config.base_saml_location = saml_url
      config.session_expiry = 86400
      config.name_id.formats = {
        email_address: ->(principal) { principal.email },
        transient: ->(principal) { principal.user_login_id },
        persistent: ->(principal) { principal.user_login_id },
        name: ->(principal) { principal.name },
      }
      config.attributes = {
        'eduPersonPrincipalName' => {
          'name' => 'urn:oid:1.3.6.1.4.1.5923.1.1.1.6',
          'name_format' => 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri',
          'getter' => ->(principal) { principal.email },
        },
      }
      config.attribute_service_location = "#{saml_url}/attributes"
      config.single_service_post_location = "#{saml_url}/auth"
      config.single_logout_service_post_location = "#{saml_url}/logout"
      config.single_logout_service_redirect_location = "#{saml_url}/logout"
    end
  end
end
