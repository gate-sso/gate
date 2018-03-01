class AddHostMachineToIpAddress < ActiveRecord::Migration
  def change
    add_reference :ip_addresses, :host_machine, index: true, foreign_key: true
  end
end
