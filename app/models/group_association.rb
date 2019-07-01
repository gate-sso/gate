class GroupAssociation < ApplicationRecord
  has_paper_trail
  belongs_to :user
  belongs_to :group

  def self.revoke_expired
    delete_all
  end
end
