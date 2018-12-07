class DropSamlServiceProviders < ActiveRecord::Migration[5.0]
  def change
    drop_table :saml_service_providers
  end
end
