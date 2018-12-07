class AddDefaultAdminsToHostMachines < ActiveRecord::Migration[5.0]
  def change
    add_column :host_machines, :default_admins, :boolean, default: true
  end
end
