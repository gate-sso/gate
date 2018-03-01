class AddApiKeyToHostMachines < ActiveRecord::Migration
  def change
    add_column :host_machines, :api_key, :string
  end
end
