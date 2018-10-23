class Datadog < SamlApp

  def initialize(org_id)
    @app_name = 'datadog'
    super(org_id)
    if @config.persisted?
      @client = DataDogClient.new(
        @config.config['app_key'],
        @config.config['api_key']
      )
    else
      @config.config = { app_key: '', api_key: '' }
    end
  end

  def save_config(sso_url, config = {})
    @config.config = @config.config.merge(config)
    super(sso_url, config)
  end

  def add_user(email)
    user_detail_response = @client.get_user(email)
    response = if user_detail_response.eql?({})
                 @client.new_user(email)
               else
                 @client.activate_user(email)
               end
    super(email) unless response.eql?({})
  end

  def remove_user(email)
    response = @client.deactivate_user(email)
    super(email) unless response.eql?({})
  end
end
