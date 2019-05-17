class SamlIdpController < SamlIdp::IdpController
  layout false
  before_action :setup_saml_configuration

  def show
    xml_content = SamlIdp.metadata.signed
    if params.key?(:download)
      send_data xml_content,
        type: 'text/xml',
        filename: 'metadata.xml'
    else
      render xml: xml_content
    end
  end

  private

  def idp_authenticate(email, password)
    user = User.find_and_validate_saml_user(email, password, params[:app])
    user.present? ? user : nil
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
    app = params[:app]
    org = Organisation.find_by_slug(slug)
    saml_url = "#{ENV['GATE_URL']}#{slug}/#{app}/saml"
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
