FactoryBot.define do
  factory :host_machine do
    sequence(:name) { |n| "host-#{n}" }
  end
end
