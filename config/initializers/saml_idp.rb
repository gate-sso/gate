SamlIdp.configure do |config|
  config.session_expiry = 86400
  config.name_id.formats = {
    email_address: -> (principal) { principal.email_address },
    transient: -> (principal) {principal.user_login_id},
    persistent: -> (principal) {principal.user_login_id},
    name: -> (principal) {principal.name},
  }
  config.attributes = {
    'eduPersonPrincipalName' => {
      'name' => 'urn:oid:1.3.6.1.4.1.5923.1.1.1.6',
      'name_format' => 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri',
      'getter' => ->(principal) { "#{principal.email}" }
    },
    EmailAddress: { getter: :email_address  },
    FirstName: { getter: :name  },
    LastName: { getter: :name  }
  }
end
