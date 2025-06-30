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

RSpec.describe BondAsset, type: :model do
  describe 'inheritance' do
    it 'inherits from Asset' do
      expect(BondAsset.superclass).to eq(Asset)
    end

    it 'has correct type' do
      bond_asset = create(:bond_asset)
      expect(bond_asset.type).to eq('BondAsset')
    end
  end

  describe 'factory' do
    it 'creates a valid bond asset' do
      bond_asset = build(:bond_asset)
      expect(bond_asset).to be_valid
    end

    it 'associates with bonds category' do
      bond_asset = create(:bond_asset)
      expect(bond_asset.category.name).to eq('Bonds')
    end
  end

  describe 'inherited behavior' do
    let(:bond_asset) { create(:bond_asset) }

    it 'inherits asset validations' do
      bond_asset.name = nil
      expect(bond_asset).not_to be_valid
      expect(bond_asset.errors[:name]).to include("can't be blank")
    end

    it 'inherits asset associations' do
      expect(bond_asset).to respond_to(:category)
      expect(bond_asset).to respond_to(:asset_prices)
      expect(bond_asset).to respond_to(:investment_transactions)
    end

    it 'inherits asset methods' do
      expect(bond_asset).to respond_to(:latest_price)
      expect(bond_asset).to respond_to(:sync_price)
    end
  end
end
