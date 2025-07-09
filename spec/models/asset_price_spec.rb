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
require 'rails_helper'

RSpec.describe AssetPrice, type: :model do
  let(:category) { create(:category, name: 'Stocks') }
  let(:asset) { create(:stock_asset, category: category, name: 'VIC') }

  describe 'validations' do
    it 'validates presence of price' do
      asset_price = build(:asset_price, asset: asset, price: nil)
      expect(asset_price).not_to be_valid
      expect(asset_price.errors[:price]).to include("can't be blank")
    end

    it 'validates presence of synced_at' do
      asset_price = build(:asset_price, asset: asset, synced_at: nil)
      expect(asset_price).not_to be_valid
      expect(asset_price.errors[:synced_at]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'belongs to asset' do
      association = described_class.reflect_on_association(:asset)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe 'callbacks' do
    it 'broadcasts price update after creation' do
      expect(ActionCable.server).to receive(:broadcast).with(
        'asset_price_updates',
        hash_including(
          asset_price: hash_including(
            asset_id: asset.id,
            asset_name: asset.name,
            category: category.name
          ),
          type: 'asset_price_created'
        )
      )

      create(:asset_price, asset: asset, price: 100.0, synced_at: Time.current)
    end
  end
end
