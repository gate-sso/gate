class ApiResource < ActiveRecord::Base
  attr_accessor :access_key

  validates :name, format: { with: /\A[a-zA-Z0-9_-]+\Z/ }, uniqueness: true, presence: true
  validates :access_key, presence: true, on: :create
  belongs_to :user
  belongs_to :group

  before_save :hash_access_key!

  def self.authenticate access_key, access_token
    api_resource = ApiResource.find_by(hashed_access_key: Digest::SHA512.hexdigest(access_key))
    user = AccessToken.find_by(token: access_token).user
    api_resource.group.member? user
  end

  private

  def hash_access_key!
    self.hashed_access_key = Digest::SHA512.hexdigest self.access_key unless self.access_key.blank?
  end
end
