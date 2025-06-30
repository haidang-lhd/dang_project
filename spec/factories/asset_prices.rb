# frozen_string_literal: true

# == Schema Information
#
# Table name: asset_prices
#
#  id         :bigint           not null, primary key
#  price      :decimal(15, 2)   not null
#  synced_at  :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  asset_id   :bigint           not null
#
# Indexes
#
#  index_asset_prices_on_asset_id  (asset_id)
#
# Foreign Keys
#
#  fk_rails_...  (asset_id => assets.id)
#
FactoryBot.define do
  factory :asset_price do
    price { Faker::Number.decimal(l_digits: 5, r_digits: 2) }
    synced_at { Time.current }
    association :asset

    trait :historical do
      synced_at { Faker::Time.between(from: 1.year.ago, to: Time.current) }
    end

    trait :recent do
      synced_at { 1.day.ago }
    end

    trait :current do
      synced_at { Time.current }
    end

    trait :high_price do
      price { Faker::Number.between(from: 1000, to: 10_000) }
    end

    trait :low_price do
      price { Faker::Number.between(from: 1, to: 100) }
    end
  end
end
