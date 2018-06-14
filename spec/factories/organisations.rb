FactoryBot.define do
  factory :organisation do
    name Faker::Company.name
    url Faker::Internet.url
    email_domain Faker::Internet.email.split('@').last
  end
end
