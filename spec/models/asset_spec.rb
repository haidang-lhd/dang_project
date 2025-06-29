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

RSpec.describe Asset, type: :model do
  describe 'associations' do
    it { should belong_to(:category) }
    it { should have_many(:asset_prices) }
    it { should have_many(:investment_transactions) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:category) }
    it { should validate_inclusion_of(:type).in_array(%w[FundAsset StockAsset GoldAsset BondAsset RealEstateAsset CryptocurrencyAsset]) }
  end

  describe 'factory' do
    it 'creates a valid asset' do
      asset = build(:asset)
      expect(asset).to be_valid
    end

    it 'creates assets with different names' do
      asset1 = create(:asset)
      asset2 = create(:asset)
      expect(asset1.name).not_to eq(asset2.name)
    end
  end

  describe 'STI inheritance' do
    it 'uses type column for inheritance' do
      expect(Asset.inheritance_column).to eq('type')
    end
  end

  describe 'instance methods' do
    let(:asset) { create(:asset) }

    describe '#latest_price' do
      context 'when asset has prices' do
        let!(:old_price) { create(:asset_price, asset: asset, synced_at: 2.days.ago) }
        let!(:latest_price) { create(:asset_price, asset: asset, synced_at: 1.day.ago) }

        it 'returns the most recent price' do
          expect(asset.latest_price).to eq(latest_price)
        end
      end

      context 'when asset has no prices' do
        it 'returns nil' do
          expect(asset.latest_price).to be_nil
        end
      end
    end

    describe '#sync_price' do
      it 'creates a new asset price' do
        expect { asset.sync_price }.to change(asset.asset_prices, :count).by(1)
      end

      it 'sets the synced_at to current time' do
        asset.sync_price
        expect(asset.asset_prices.last.synced_at).to be_within(1.second).of(Time.current)
      end

      it 'sets placeholder price' do
        asset.sync_price
        expect(asset.asset_prices.last.price).to eq(0.0)
      end
    end
  end

  describe 'traits' do
    it 'creates asset with prices' do
      asset = create(:asset, :with_prices)
      expect(asset.asset_prices.count).to eq(3)
    end

    it 'creates asset with transactions' do
      asset = create(:asset, :with_transactions)
      expect(asset.investment_transactions.count).to eq(2)
    end
  end
end
