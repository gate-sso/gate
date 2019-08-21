class GroupEndpoint < ApplicationRecord
  belongs_to :group
  belongs_to :endpoint

  validates :group, uniqueness: { scope: :endpoint }
end
