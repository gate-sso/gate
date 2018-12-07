class AddProvisioningUriToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :provisioning_uri, :string
  end
end
