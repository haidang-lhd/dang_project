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
require 'rails_helper'

RSpec.describe StockAsset, type: :model do
  describe 'inheritance' do
    it 'inherits from Asset' do
      expect(StockAsset.superclass).to eq(Asset)
    end

    it 'has correct type' do
      stock_asset = create(:stock_asset)
      expect(stock_asset.type).to eq('StockAsset')
    end
  end

  describe 'factory' do
    it 'creates a valid stock asset' do
      stock_asset = build(:stock_asset)
      expect(stock_asset).to be_valid
    end

    it 'associates with stocks category' do
      stock_asset = create(:stock_asset)
      expect(stock_asset.category.name).to eq('Stocks')
    end
  end

  describe 'traits' do
    it 'creates VPB stock asset' do
      stock_asset = create(:stock_asset, :vpb)
      expect(stock_asset.name).to eq('VPB')
    end
  end

  describe 'inherited behavior' do
    let(:stock_asset) { create(:stock_asset) }

    it 'inherits asset validations' do
      stock_asset.name = nil
      expect(stock_asset).not_to be_valid
      expect(stock_asset.errors[:name]).to include("can't be blank")
    end

    it 'inherits asset associations' do
      expect(stock_asset).to respond_to(:category)
      expect(stock_asset).to respond_to(:asset_prices)
      expect(stock_asset).to respond_to(:investment_transactions)
    end

    it 'inherits asset methods' do
      expect(stock_asset).to respond_to(:latest_price)
      expect(stock_asset).to respond_to(:sync_price)
    end
  end
end
