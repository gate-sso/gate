class GroupEndpoint < ApplicationRecord
  has_paper_trail

  belongs_to :group
  belongs_to :endpoint

  validates :group, uniqueness: { scope: :endpoint }
  validates_presence_of :group
  validates_presence_of :endpoint
end
