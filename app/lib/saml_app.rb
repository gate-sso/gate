class SamlApp

  attr_accessor :config, :app_name

  def initialize(org_id)
    @config = SamlAppConfig.find_or_initialize_by(
      app_name: @app_name, organisation_id: org_id
    )
  end

  def save_config(sso_url, config = {})
    unless @config.persisted?
      @config.group = Group.find_or_create_by(name: "saml_#{app_name}_users")
    end
    @config.sso_url = sso_url
    @config.save
  end
end
