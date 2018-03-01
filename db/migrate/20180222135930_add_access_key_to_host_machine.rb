class AddAccessKeyToHostMachine < ActiveRecord::Migration
  def change
    add_column :host_machines, :access_key, :string
  end
end
