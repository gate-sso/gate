FactoryBot.define do
  factory :saml_app_config do
    sso_url { Faker::Internet.url }
    group { create(:group, name: 'saml_datadog_users') }
    config { { app_key: Faker::Internet.password(8), api_key: Faker::Internet.password(8) } }
    organisation { build(:organisation) }
    app_name { 'datadog' }
  end
end
