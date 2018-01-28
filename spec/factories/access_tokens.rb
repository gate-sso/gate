FactoryGirl.define do
  factory :access_token do
    token SecureRandom.uuid
  end
end
