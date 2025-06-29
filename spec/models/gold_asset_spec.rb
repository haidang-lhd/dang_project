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

RSpec.describe GoldAsset, type: :model do
  describe 'inheritance' do
    it 'inherits from Asset' do
      expect(GoldAsset.superclass).to eq(Asset)
    end

    it 'has correct type' do
      gold_asset = create(:gold_asset)
      expect(gold_asset.type).to eq('GoldAsset')
    end
  end

  describe 'factory' do
    it 'creates a valid gold asset' do
      gold_asset = build(:gold_asset)
      expect(gold_asset).to be_valid
    end

    it 'associates with gold category' do
      gold_asset = create(:gold_asset)
      expect(gold_asset.category.name).to eq('Gold')
    end
  end

  describe 'traits' do
    it 'creates SJC gold asset' do
      gold_asset = create(:gold_asset, :sjc)
      expect(gold_asset.name).to eq('SJC')
    end

    it 'creates DOJI gold asset' do
      gold_asset = create(:gold_asset, :doji)
      expect(gold_asset.name).to eq('DOJI')
    end
  end

  describe 'inherited behavior' do
    let(:gold_asset) { create(:gold_asset) }

    it 'inherits asset validations' do
      gold_asset.name = nil
      expect(gold_asset).not_to be_valid
      expect(gold_asset.errors[:name]).to include("can't be blank")
    end

    it 'inherits asset associations' do
      expect(gold_asset).to respond_to(:category)
      expect(gold_asset).to respond_to(:asset_prices)
      expect(gold_asset).to respond_to(:investment_transactions)
    end

    it 'inherits asset methods' do
      expect(gold_asset).to respond_to(:latest_price)
      expect(gold_asset).to respond_to(:sync_price)
    end
  end
end
