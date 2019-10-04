FactoryBot.define do
  factory :user do
    transient do
      user_roles_list { ENV['USER_ROLES'].split(',') }
      hosted_domains_list { ENV['GATE_HOSTED_DOMAINS'].split(',') }
    end
    first_name { Faker::Name.first_name.gsub(/[^A-Za-z]/, '') }
    last_name { Faker::Name.last_name.gsub(/[^A-Za-z]/, '') }
    user_role { user_roles_list.sample }
    mobile { Faker::PhoneNumber.cell_phone }
    email { "#{first_name.downcase}.#{last_name.downcase}@#{hosted_domains_list.sample}" }
    alternate_email { Faker::Internet.email }
    name { "#{first_name} #{last_name}" }
    active { true }
    admin { true }
    sequence(:reset_password_token) { |n| "user_secret#{n}" }
    after(:create) do |user, _evaluator|
      user.assign_attributes(
        user_login_id: user.generate_login_id, uid: user.generate_uid
      )
      user.initialise_host_and_group
      user.save!
    end
  end

  factory :group_admin, class: User do
    transient do
      user_roles_list { ENV['USER_ROLES'].split(',') }
      hosted_domains_list { ENV['GATE_HOSTED_DOMAINS'].split(',') }
    end
    first_name { Faker::Name.first_name.gsub(/[^A-Za-z]/, '') }
    last_name { Faker::Name.last_name.gsub(/[^A-Za-z]/, '') }
    user_role { user_roles_list.sample }
    alternate_email { Faker::Internet.email }
    mobile { Faker::PhoneNumber.cell_phone }
    active { true }
    admin { true }
    email { "#{first_name.downcase}.#{last_name.downcase}@#{hosted_domains_list.sample}" }
    name { "#{first_name} #{last_name}" }
    sequence(:reset_password_token) { |n| "secret#{n}" }
    after(:create) do |user, _evaluator|
      user.assign_attributes(
        user_login_id: user.generate_login_id, uid: user.generate_uid
      )
      user.initialise_host_and_group
      user.save!
    end
  end

  factory :admin_user, class: User do
    transient do
      user_roles_list { ENV['USER_ROLES'].split(',') }
      hosted_domains_list { ENV['GATE_HOSTED_DOMAINS'].split(',') }
    end
    first_name { Faker::Name.first_name.gsub(/[^A-Za-z]/, '') }
    last_name { Faker::Name.last_name.gsub(/[^A-Za-z]/, '') }
    user_role { user_roles_list.sample }
    alternate_email { Faker::Internet.email }
    mobile { Faker::PhoneNumber.cell_phone }
    active { true }
    admin { true }
    email { "#{first_name.downcase}.#{last_name.downcase}@#{hosted_domains_list.sample}" }
    name { "#{first_name} #{last_name}" }
    sequence(:reset_password_token) { |n| "secret#{n}" }
    after(:create) do |user, _evaluator|
      user.assign_attributes(
        user_login_id: user.generate_login_id, uid: user.generate_uid
      )
      user.initialise_host_and_group
      user.save!
    end
  end
end
