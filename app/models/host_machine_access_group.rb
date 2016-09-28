class HostMachineAccessGroup < ActiveRecord::Base
  belongs_to :host_machine
  belongs_to :host_access_group
end
