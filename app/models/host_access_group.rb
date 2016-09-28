class HostAccessGroup < ActiveRecord::Base
  has_many :users, through: :user_host_access_groups
  has_many :host_machines, through: :host_machine_access_groups
end
