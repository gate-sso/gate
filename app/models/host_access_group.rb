class HostAccessGroup < ActiveRecord::Base
  belongs_to :host_machine
  belongs_to :group
  
end
