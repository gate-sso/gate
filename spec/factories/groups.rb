FactoryBot.define do
  factory :group do
    sequence(:name, 1000) { |n| "People#{n}" }
  end
end
