# frozen_string_literal: true

# == Schema Information
#
# Table name: assets
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint           not null
#
# Indexes
#
#  index_assets_on_category_id  (category_id)
#  index_assets_on_type         (type)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#
FactoryBot.define do
  factory :asset do
    sequence(:name) { |n| "Asset #{n}" }
    association :category

    factory :fund_asset, class: 'FundAsset' do
      type { 'FundAsset' }
      association :category, :investment_fund_certificates

      trait :vesaf do
        name { 'VESAF' }
      end

      trait :vmeef do
        name { 'VMEEF' }
      end
    end

    factory :stock_asset, class: 'StockAsset' do
      type { 'StockAsset' }
      association :category, :stocks

      trait :vpb do
        name { 'VPB' }
      end
    end

    factory :gold_asset, class: 'GoldAsset' do
      type { 'GoldAsset' }
      association :category, :gold

      trait :sjc do
        name { 'SJC' }
      end

      trait :doji do
        name { 'DOJI' }
      end
    end

    factory :cryptocurrency_asset, class: 'CryptocurrencyAsset' do
      type { 'CryptocurrencyAsset' }
      association :category, :cryptocurrency

      trait :bitcoin do
        name { 'BTC' }
      end
    end

    factory :bond_asset, class: 'BondAsset' do
      type { 'BondAsset' }
      association :category, :bonds
    end

    factory :real_estate_asset, class: 'RealEstateAsset' do
      type { 'RealEstateAsset' }
      association :category, :real_estate
    end

    trait :with_prices do
      after(:create) do |asset|
        create_list(:asset_price, 3, asset: asset)
      end
    end

    trait :with_transactions do
      after(:create) do |asset|
        create_list(:investment_transaction, 2, asset: asset)
      end
    end
  end
end
