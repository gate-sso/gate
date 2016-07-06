class AddProvisioningUriToUser < ActiveRecord::Migration
  def change
    add_column :users, :provisioning_uri, :string
  end
end
