class Host < ApplicationRecord
  has_paper_trail
  belongs_to :user
  acts_as_paranoid
end
