namespace :app do
  desc "Common app related tasks"

  task :init do
    cp '.env.sample', '.env'
    puts "\nPlease update you .env file with proper values."
  end

  task :setup do
    sh "bundle install"
    sh "bundle exec rake db:drop db:create db:migrate"
  end

  task :start => [:setup] do
    sh "rails server"
  end

  task :rspec do
    sh "RAILS_ENV=test DB_NAME=gate_test bundle exec rake spec"
  end

  task :db_setup do
    sh "bundle exec rake db:setup"
  end

  task :migrate do
    sh "bundle exec rake db:migrate"
  end

  task :rc do
    sh "rails console"
  end

  task :routes do
    sh "bundle exec rake routes"
  end
end
