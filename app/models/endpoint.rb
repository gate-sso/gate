class Endpoint < ApplicationRecord
  validates_presence_of :path
  validates_presence_of :method
  validates :method, inclusion: { in: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'] }
end
