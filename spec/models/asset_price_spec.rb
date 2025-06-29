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
  describe 'associations' do
    it { should belong_to(:asset) }
  end

  describe 'validations' do
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:synced_at) }
  end

  describe 'factory' do
    it 'creates a valid asset price' do
      asset_price = build(:asset_price)
      expect(asset_price).to be_valid
    end

    it 'generates random price' do
      asset_price1 = create(:asset_price)
      asset_price2 = create(:asset_price)
      expect(asset_price1.price).not_to eq(asset_price2.price)
    end
  end

  describe 'traits' do
    it 'creates historical price' do
      asset_price = create(:asset_price, :historical)
      expect(asset_price.synced_at).to be < Time.current
      expect(asset_price.synced_at).to be > 1.year.ago
    end

    it 'creates recent price' do
      asset_price = create(:asset_price, :recent)
      expect(asset_price.synced_at).to be_within(1.hour).of(1.day.ago)
    end

    it 'creates current price' do
      asset_price = create(:asset_price, :current)
      expect(asset_price.synced_at).to be_within(1.second).of(Time.current)
    end

    it 'creates high price' do
      asset_price = create(:asset_price, :high_price)
      expect(asset_price.price).to be >= 1000
      expect(asset_price.price).to be <= 10000
    end

    it 'creates low price' do
      asset_price = create(:asset_price, :low_price)
      expect(asset_price.price).to be >= 1
      expect(asset_price.price).to be <= 100
    end
  end

  describe 'database constraints' do
    it 'requires price to be present' do
      asset_price = build(:asset_price, price: nil)
      expect(asset_price).not_to be_valid
      expect(asset_price.errors[:price]).to include("can't be blank")
    end

    it 'requires synced_at to be present' do
      asset_price = build(:asset_price, synced_at: nil)
      expect(asset_price).not_to be_valid
      expect(asset_price.errors[:synced_at]).to include("can't be blank")
    end
  end

  describe 'decimal precision' do
    it 'stores price with correct precision' do
      asset_price = create(:asset_price, price: 123.45)
      expect(asset_price.reload.price).to eq(123.45)
    end
  end
end
