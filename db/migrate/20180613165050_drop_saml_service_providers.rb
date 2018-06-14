class DropSamlServiceProviders < ActiveRecord::Migration
  def change
    drop_table :saml_service_providers
  end
end
