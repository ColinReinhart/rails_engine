FactoryBot.define do
  factory :item do
    name { Faker::Commerce.product_name }
    description { Faker::ChuckNorris.fact }
    unit_price { Faker::Commerce.price }
    merchant { nil }
  end
end
