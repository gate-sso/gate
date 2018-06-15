FactoryBot.define do
  sequence(:name) { |n| "#{Faker::Name.name}#{n}" }
  sequence(:email) do |n|
    email = Faker::Internet.email
    "#{email.split('@').first}_#{n}@#{email.split('@').last}"
  end

  factory :user do
    name
    email
    active true
    admin true
    sequence(:reset_password_token) { |n| "secret#{n}" }
    after(:create) do |user, _evaluator|
      user.assign_attributes(
        user_login_id: user.generate_login_id, uid: user.generate_uid
      )
      user.initialise_host_and_group
      user.save!
    end
  end

  factory :group_admin, class: User do
    name
    email
    active true
    admin true
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
    name
    email
    active true
    admin true
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
