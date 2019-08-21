class Endpoint < ApplicationRecord
  validates_presence_of :path
  validates_presence_of :method
  validates :method, inclusion: { in: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'] }
  validates_format_of :path, with: /\A(\/(([0-9, a-z,\-,_]+)|(:[a-z]+))*)+\Z/i
end
