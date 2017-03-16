namespace :users do
  desc "imports users and prints their keys"
  task import_csv: :environment do
    require 'csv'
    CSV.foreach("users.csv") do |row|
      #Name, UserName
      key = User.add_temp_user(row[0], row[1])
      puts ("#{key}, #{row[0]}, #{row[1]}, #{row[2]}")
    end
  end

end
