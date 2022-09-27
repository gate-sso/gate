class VpnGroupAssociation < ApplicationRecord
  belongs_to :vpn
  belongs_to :group
end

