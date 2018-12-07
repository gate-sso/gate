class CreateSamlServiceProviders < ActiveRecord::Migration[5.0]
  def change
    create_table :saml_service_providers do |t|
      t.string :name, null: false, unique: true
      t.string :sso_url, null: false, unique: true
      t.string :metadata_url, null: false, unique: true

      t.timestamps null: false
    end
  end
end
