require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
Figaro.env.RAILS_ENV ||= 'test'

module ActiveSupport
  class TestCase
    # Setup all fixtures in test/fixtures/*.yml
    # for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
