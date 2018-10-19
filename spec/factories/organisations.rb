FactoryBot.define do
  country = Country.find_country_by_name(Country.all.map(&:name).sort.sample)
  factory :organisation do
    sequence(:slug) { |n| "#{Faker::Lorem.word}_#{n}" }
    name { Faker::Lorem.word }
    website { Faker::Internet.url }
    domain { Faker::Internet.email.split('@').last }
    country { country.gec }
    state { Faker::Address.state }
    address { Faker::Lorem.words(3).join(' ') }
    unit_name { 'IT' }
    admin_email_address { Faker::Internet.email }
  end
end
