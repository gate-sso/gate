class AccessToken < ApplicationRecord
  attr_accessor :token


  belongs_to :user

  before_save :hash_token!

  def self.find_token challenge_token
    AccessToken.where(hashed_token: Digest::SHA512.hexdigest(challenge_token)).first
  end

  def self.valid_token challenge_token
    find_token(challenge_token).present?
  end

  private

  def hash_token!
    self.hashed_token = Digest::SHA512.hexdigest self.token unless self.token.blank?
  end
end
