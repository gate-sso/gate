class AddDefaultAdminsToHostMachines < ActiveRecord::Migration
  def change
    add_column :host_machines, :default_admins, :boolean, default: true
  end
end
