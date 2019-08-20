FactoryBot.define do
  factory :endpoint do
    path { '/' }
    add_attribute(:method) { ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'].sample }
  end
end
