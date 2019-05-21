namespace :app do
  desc "Common app related tasks"

  task :init do
    cp '.env.example', '.env'
    p 'Please read information @ README.md - Setting up Environment Variables'
  end

  task :setup do
    sh "bundle install"
    sh "bundle exec rake db:drop db:create db:migrate"
    sh "RAILS_ENV=test bundle exec rake db:migrate"
    sh "RAILS_ENV=test bundle exec rspec"
  end
end
