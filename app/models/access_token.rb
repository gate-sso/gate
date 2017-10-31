class AccessToken < ActiveRecord::Base
  has_paper_trail
  def self.valid_token token
    token = AccessToken.where(token: token) if token.present?
    return token.present?
  end
end
