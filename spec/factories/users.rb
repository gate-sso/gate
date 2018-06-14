FactoryBot.define do
  factory :user do
    sequence(:name){|n| "TestUser#{n}}"}
    sequence(:user_login_id){|n| "test#{n}}"}
    sequence(:email) {|n| "test#{n}@test.com"}
    active true
    admin false
    sequence(:reset_password_token) {|n| "secret#{n}" }
    after(:create) do |user, evaluator|
      group = Group.first
      user.groups << group unless group.blank?
      group = Group.create(name: user.user_login_id)
      user.groups << group
      user.save!
    end
  end
  factory :group_admin, class: User do
    sequence(:name){|n| "TestUser#{n}}"}
    sequence(:user_login_id){|n| "test#{n}}"}
    sequence(:email) {|n| "test#{n}@test.com"}
    active true
    admin false
    sequence(:reset_password_token) {|n| "secret#{n}" }
    after(:create) do |user, evaluator|
      group = Group.first
      user.groups << group unless group.blank?
      group = Group.create(name: user.user_login_id)
      user.groups << group
      user.save!
      GroupAdmin.create(user: user, group: group)
    end
  end
  factory :admin_user, class: User do
    sequence(:name){|n| "TestUser#{n}}"}
    sequence(:user_login_id){|n| "test#{n}}"}
    sequence(:email) {|n| "test#{n}@test.com"}
    active true
    admin true
    sequence(:reset_password_token) {|n| "secret#{n}" }
    after(:create) do |user, evaluator|
      group = Group.first
      user.groups << group unless group.blank?
      group = Group.create(name: user.user_login_id)
      user.groups << group
      user.save!
    end
  end
end
