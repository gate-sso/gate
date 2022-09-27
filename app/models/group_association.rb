class GroupAssociation < ApplicationRecord
  belongs_to :user
  belongs_to :group

  def self.revoke_expired(date = Date.today)
    where('expiration_date < ?', date).destroy_all
  end
end
