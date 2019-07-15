ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __dir__)
require 'dredd_hooks/methods'

include DreddHooks::Methods

before_all do |_|
  user = User.create(name: 'foo', email: 'bar@test.com', admin: 1)
  access_token = AccessToken.new
  access_token.token = 'token'
  access_token.user = user
  user.access_token = access_token
  access_token.save!
  user.save!
  inactive_user = User.create(name: 'foo', email: 'foo@test2.com', active: 0, user_login_id: 'foo')
  inactive_user.save!
  active_user = User.create(name: 'foo', email: 'foo@test.com', active: 1, user_login_id: 'foo')
  active_user.save!
end
