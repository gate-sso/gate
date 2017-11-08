class Host < ActiveRecord::Base
  has_paper_trail
  belongs_to :user
  acts_as_paranoid
end
