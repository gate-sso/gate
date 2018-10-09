class AccessToken < ApplicationRecord
  attr_accessor :token

  has_paper_trail

  belongs_to :user

  before_save :hash_token!

  def self.valid_token challenge_token
    token = AccessToken.where(hashed_token: Digest::SHA512.hexdigest(challenge_token))
    return token.present?
  end

  private

  def hash_token!
    self.hashed_token = Digest::SHA512.hexdigest self.token unless self.token.blank?
  end
end
