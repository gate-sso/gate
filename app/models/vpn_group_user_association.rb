class VpnGroupUserAssociation < ApplicationRecord
  belongs_to :vpn
  belongs_to :user
end


