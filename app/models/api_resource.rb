class ApiResource < ActiveRecord::Base
  validates :name, format: { with: /\A[a-zA-Z0-9_-]+\Z/ }, presence: true
  validates :access_key, presence: true
  belongs_to :user
  belongs_to :group
end
