namespace :app do
  desc "Common app related tasks"

  task :init do
    cp 'config/application.yml.sample', 'config/application.yml'
    p 'Please read information @ README.md - Setting up Configuration'
  end

  task :setup do
    sh "bundle install"
    sh "bundle exec rake db:drop db:create db:migrate"
    sh "RAILS_ENV=test bundle exec rake db:migrate"
    sh "RAILS_ENV=test bundle exec rspec"
  end
end
