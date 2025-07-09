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
    association :asset
    price { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    synced_at { Time.current }
  end
end
