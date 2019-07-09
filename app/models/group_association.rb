class GroupAssociation < ApplicationRecord
  has_paper_trail
  belongs_to :user
  belongs_to :group

  def self.revoke_expired(date = Date.today)
    where('expiration_date < ?', date).delete_all
  end
end
