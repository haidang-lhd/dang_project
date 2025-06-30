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

RSpec.describe RealEstateAsset, type: :model do
  describe 'inheritance' do
    it 'inherits from Asset' do
      expect(RealEstateAsset.superclass).to eq(Asset)
    end

    it 'has correct type' do
      real_estate_asset = create(:real_estate_asset)
      expect(real_estate_asset.type).to eq('RealEstateAsset')
    end
  end

  describe 'factory' do
    it 'creates a valid real estate asset' do
      real_estate_asset = build(:real_estate_asset)
      expect(real_estate_asset).to be_valid
    end

    it 'associates with real estate category' do
      real_estate_asset = create(:real_estate_asset)
      expect(real_estate_asset.category.name).to eq('Real Estate')
    end
  end

  describe 'inherited behavior' do
    let(:real_estate_asset) { create(:real_estate_asset) }

    it 'inherits asset validations' do
      real_estate_asset.name = nil
      expect(real_estate_asset).not_to be_valid
      expect(real_estate_asset.errors[:name]).to include("can't be blank")
    end

    it 'inherits asset associations' do
      expect(real_estate_asset).to respond_to(:category)
      expect(real_estate_asset).to respond_to(:asset_prices)
      expect(real_estate_asset).to respond_to(:investment_transactions)
    end

    it 'inherits asset methods' do
      expect(real_estate_asset).to respond_to(:latest_price)
      expect(real_estate_asset).to respond_to(:sync_price)
    end
  end
end
