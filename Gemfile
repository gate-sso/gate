source 'https://rubygems.org'

gem 'rails', '4.2.6'

gem "paranoia"

platform :ruby do
  gem 'sqlite3'
end

gem 'mysql2', platform: :ruby
platform :jruby do
  gem 'jdbc-mysql'
  gem 'activerecord-jdbc-adapter'
end

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
#gem 'net-openvpn'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'redis'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :ruby
  gem 'pry'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0', platform: :ruby

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  #gem 'spring', platform: :ruby
end

gem 'puma'

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails'
end

gem "slim-rails"

gem "twitter-bootstrap-rails"

#gem 'therubyracer', platform: :ruby
gem 'rotp'
gem 'therubyrhino', platform: :jruby

gem 'devise', '4.1.0'
gem 'omniauth'
gem 'omniauth-google-oauth2' 
