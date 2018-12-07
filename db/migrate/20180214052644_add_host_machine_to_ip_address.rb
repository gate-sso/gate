class AddHostMachineToIpAddress < ActiveRecord::Migration[5.0]
  def change
    add_reference :ip_addresses, :host_machine, index: true, foreign_key: true
  end
end
