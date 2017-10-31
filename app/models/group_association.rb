class GroupAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  has_paper_trail
end
