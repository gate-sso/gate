class Vpn < ActiveRecord::Base
  has_paper_trail
  belongs_to :user
  belongs_to :group

  has_many :vpn_group_associations
  has_many :groups, through: :vpn_group_associations

  has_many :vpn_group_user_associations
  has_many :users, through: :vpn_group_user_associations
end
