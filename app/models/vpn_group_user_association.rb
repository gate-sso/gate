class VpnGroupUserAssociation < ApplicationRecord
  has_paper_trail
  belongs_to :vpn
  belongs_to :user
end


