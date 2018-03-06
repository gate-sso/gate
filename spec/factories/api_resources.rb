FactoryBot.define do
  factory :api_resource do
    sequence(:name, 1000) { |n| "API#{n}" }
    description "MyString"
    access_key "MyString"
  end
end
