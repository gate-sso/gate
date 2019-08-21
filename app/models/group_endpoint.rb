class GroupEndpoint < ApplicationRecord
  belongs_to :group
  belongs_to :endpoint

  validates :group, uniqueness: { scope: :endpoint }
  validates_presence_of :group
end
