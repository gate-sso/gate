class HostMachine < ActiveRecord::Base
  has_many :host_machine_groups
  has_many :users, through: :host_machine_groups
end
