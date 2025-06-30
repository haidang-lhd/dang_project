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
class Asset < ApplicationRecord
  self.inheritance_column = :type
  belongs_to :category
  has_many :asset_prices
  has_many :investment_transactions

  validates :name, presence: true
  validates :category, presence: true
  validates :type, inclusion: { in: %w[FundAsset StockAsset GoldAsset BondAsset RealEstateAsset CryptocurrencyAsset] }, allow_nil: true

  def latest_price
    asset_prices.order(synced_at: :desc).first
  end

  def sync_price
    asset_prices.create!(
      price: 0.0, # Placeholder for actual price fetching logic
      synced_at: Time.current
    )
  end

  def manual_set_price(price)
    asset_prices.create!(
      price: price,
      synced_at: Time.current
    )
  end
end
