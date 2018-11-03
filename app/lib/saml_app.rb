class SamlApp

  attr_accessor :config, :app_name

  def initialize(org_id)
    @config = SamlAppConfig.find_or_initialize_by(
      app_name: @app_name, organisation_id: org_id
    )
  end

  def save_config(sso_url, config = {})
    unless @config.persisted?
      group_name = "#{@config.organisation.slug}_saml_#{app_name}_users"
      @config.group = Group.find_or_create_by(name: group_name)
    end
    @config.sso_url = sso_url
    @config.save
  end

  def add_user(email)
    user = User.where(email: email).first
    unless user.blank?
      @config.group.add_user(user.id)
      return true
    end
    false
  end

  def remove_user(email)
    user = User.where(email: email).first
    unless user.blank?
      @config.group.remove_user(user.id)
      return true
    end
    false
  end
end
