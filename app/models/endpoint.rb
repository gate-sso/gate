class Endpoint < ApplicationRecord
  has_paper_trail

  has_many :group_endpoints
  has_many :groups, through: :group_endpoints

  validates_presence_of :path
  validates_presence_of :method
  validates :method, inclusion: { in: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'] }
  validates_format_of :path, with: /\A((\/(([0-9, a-z,\-,_]+)|(:[a-z]+))+)+|\/)\Z/i
end
