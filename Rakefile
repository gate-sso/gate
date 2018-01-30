# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task :init do
  cp '.env.sample', '.env'
  puts "\nPlease update you .env file with proper values."
end

task :all do
  sh "bundle install"
  sh "bundle exec rake db:drop db:create db:migrate db:seed"
  sh "rails server"
end

task :rspec do
  sh "bundle exec rake spec"
end

