class Endpoint < ApplicationRecord
  validates_presence_of :path
  validates_presence_of :method
end
