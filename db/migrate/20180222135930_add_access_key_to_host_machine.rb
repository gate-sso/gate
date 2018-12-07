class AddAccessKeyToHostMachine < ActiveRecord::Migration[5.0]
  def change
    add_column :host_machines, :access_key, :string
  end
end
