FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "People#{n}" }
  end
end
