SamlIdp.configure do |config|
  # noinspection RubyUnusedLocalVariable
  base   = ENV['GATE_SAML_IDP_BASE']
  domain = ENV['GATE_SAML_IDP_DOMAIN']

  config.x509_certificate = ENV['GATE_SAML_IDP_X509_CERTIFICATE'].gsub("\\n", "\n")
  config.secret_key = ENV['GATE_SAML_IDP_SECRET_KEY'].gsub("\\n", "\n")
  service_providers = {
      ENV['GATE_SAML_IDP_DATA_DOG_SSO_URL']  => {
          :fingerprint  => ENV['GATE_SAML_IDP_FINGERPRINT'],
          :metadata_url => ENV['GATE_SAML_IDP_DATA_DOG_METADATA_URL']
      }
  }

  config.organization_name = ENV['GATE_SAML_IDP_ORGANIZATION_NAME']
  config.organization_url  = ENV['GATE_SAML_IDP_ORGANIZATION_URL']

  config.base_saml_location           = ENV['GATE_SAML_IDP_BASE_SAML_LOCATION']
  config.single_service_post_location = ENV['GATE_SAML_IDP_SINGLE_SERVICE_POST_LOCATION']
  config.session_expiry               = ENV['GATE_SAML_IDP_SESSION_EXPIRY'].to_i

  config.name_id.formats = {
      transient:     -> (principal) {"#{principal.username}@#{domain}"},
      persistent:    -> (principal) {"#{principal.username}@#{domain}"},
      email_address: -> (principal) {"#{principal.username}@#{domain}"}
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
