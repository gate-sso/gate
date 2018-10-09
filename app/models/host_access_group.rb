class HostAccessGroup < ApplicationRecord
  belongs_to :host_machine
  belongs_to :group
end
