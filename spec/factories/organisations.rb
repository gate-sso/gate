FactoryBot.define do
  country = Country.find_country_by_name(Country.all.map(&:name).sort.sample)
  factory :organisation do
    sequence(:slug) { |n| "#{Faker::Internet.slug}_#{n}" }
    name Faker::Company.name
    website Faker::Internet.url
    domain Faker::Internet.email.split('@').last
    country country.gec
    state Faker::Address.state
    address Faker::Address.street_address
    unit_name 'IT'
    admin_email_address Faker::Internet.email
  end
end
