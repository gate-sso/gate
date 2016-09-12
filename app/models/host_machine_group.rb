class HostMachineGroup < ActiveRecord::Base
  belongs_to :user
  belongs_to :host_machine
end
