return unless (Figaro.env.ENABLE_SAML && (defined?(Rails::Server) || defined?(Rails::Console)))

SamlIdp.configure do |config|
    base = Figaro.env.GATE_SERVER_URL
    saml_base = "#{base}/saml"

    config.x509_certificate = Figaro.env.GATE_SAML_IDP_X509_CERTIFICATE.gsub("\\n", "\n")
    config.secret_key = Figaro.env.GATE_SAML_IDP_SECRET_KEY.gsub("\\n", "\n")

    service_providers = {}
    SamlServiceProvider.find_each do |sp|
      service_providers[sp.sso_url] = {
          :fingerprint => Figaro.env.GATE_SAML_IDP_FINGERPRINT,
          :metadata_url => sp.metadata_url
      }
    end

    config.organization_name = Figaro.env.GATE_SAML_IDP_ORGANIZATION_NAME
    config.organization_url = Figaro.env.GATE_SAML_IDP_ORGANIZATION_URL

    config.base_saml_location = saml_base
    config.single_service_post_location = "#{saml_base}/auth"
    config.session_expiry = Figaro.env.GATE_SAML_IDP_SESSION_EXPIRY.to_i

    config.name_id.formats = {
        email_address: -> (principal) {principal.email},
        transient: -> (principal) {principal.user_login_id},
        persistent: -> (principal) {principal.user_login_id},
        name: -> (principal) {principal.name},
    }

    config.attributes = {
        'eduPersonPrincipalName' => {
            'name' => 'urn:oid:1.3.6.1.4.1.5923.1.1.1.6',
            'name_format' => 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri',
            'getter' => ->(principal) {
              "#{principal.email}"
            }
        },
    }

    config.service_provider.metadata_persister = ->(identifier, settings) {
      fname = identifier.to_s.gsub(/\/|:/, '_')
      `mkdir -p #{Rails.root.join('cache/saml/metadata')}`
      File.open Rails.root.join("cache/saml/metadata/#{fname}"), 'r+b' do |f|
        Marshal.dump settings.to_h, f
      end
    }

    config.service_provider.persisted_metadata_getter = ->(identifier, _service_provider) {
      fname = identifier.to_s.gsub(/\/|:/, '_')
      `mkdir -p #{Rails.root.join('cache/saml/metadata')}`
      full_filename = Rails.root.join("cache/saml/metadata/#{fname}")
      if File.file?(full_filename)
        File.open full_filename, 'rb' do |f|
          Marshal.load f
        end
      end
    }

    config.service_provider.finder = ->(issuer_or_entity_id) do
      service_providers[issuer_or_entity_id]
    end
end
