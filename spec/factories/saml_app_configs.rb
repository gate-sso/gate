FactoryBot.define do
  factory :saml_app_config do
    sso_url { Faker::Internet.url }
    group { create(:group, name: "saml_#{Faker::Lorem.word}_datadog_users") }
    config { { app_key: Faker::Internet.password(min_length: 8), api_key: Faker::Internet.password(min_length: 8) } }
    organisation { build(:organisation) }
    app_name { 'datadog' }
  end
end
