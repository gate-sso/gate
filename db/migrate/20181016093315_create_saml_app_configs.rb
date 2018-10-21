class CreateSamlAppConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :saml_app_configs do |t|
      t.references :group, foreign_key: true
      t.string :sso_url
      t.json :config
      t.references :organisation, foreign_key: true
      t.string :app_name

      t.timestamps
    end
  end
end
