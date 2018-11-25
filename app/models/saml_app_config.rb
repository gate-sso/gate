class SamlAppConfig < ApplicationRecord
  belongs_to :group
  belongs_to :organisation

  serialize :config, JSON

  def self.get_config(app_name, org_id)
    SamlAppConfig.find_or_initialize_by(
      app_name: app_name, organisation_id: org_id
    )
  end
end
