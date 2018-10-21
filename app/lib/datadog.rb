class Datadog < SamlApp

  def initialize(org_id)
    @app_name = 'datadog'
    super
    unless @config.persisted?
      @config.config = { app_key: '', api_key: '' }
    end
  end

  def save_config(sso_url, config = {})
    @config.config = @config.config.merge(config)
    super(sso_url, config)
  end
end
