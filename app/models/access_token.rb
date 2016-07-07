class AccessToken < ActiveRecord::Base


  def self.valid_token token
    token = AccessToken.where(token: token) if token.present?
    return true if token.present?
    return false
  end
end
