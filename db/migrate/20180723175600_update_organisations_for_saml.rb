class UpdateOrganisationsForSaml < ActiveRecord::Migration
  def change
    rename_column :organisations, :url, :website
    rename_column :organisations, :email_domain, :domain
    add_column :organisations, :country, :string
    add_column :organisations, :state, :string
    add_column :organisations, :address, :string
    add_column :organisations, :unit_name, :string
    add_column :organisations, :admin_email_address, :string
    add_column :organisations, :slug, :string
    add_column :organisations, :cert_fingerprint, :string
    add_column :organisations, :cert_key, :text
    add_column :organisations, :cert_private_key, :text
  end
end
