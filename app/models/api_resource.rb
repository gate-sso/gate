class ApiResource < ActiveRecord::Base
  validates :name, format: { with: /\A[a-zA-Z0-9_-]+\Z/ }, uniqueness: true, presence: true
  validates :access_key, presence: true
  belongs_to :user
  belongs_to :group

  def self.authenticate access_key, access_token
    api_resource = ApiResource.find_by(access_key: access_key)
    user = AccessToken.find_by(token: access_token).user
    api_resource.group.member? user
  end
end
