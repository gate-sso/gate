FactoryBot.define do
  factory :vpn do
    sequence(:name) { |n| "VPN#{n}" }
  end
end
