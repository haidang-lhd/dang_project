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

RSpec.describe CryptocurrencyAsset, type: :model do
  describe 'inheritance' do
    it 'inherits from Asset' do
      expect(CryptocurrencyAsset.superclass).to eq(Asset)
    end

    it 'has correct type' do
      crypto_asset = create(:cryptocurrency_asset)
      expect(crypto_asset.type).to eq('CryptocurrencyAsset')
    end
  end

  describe 'factory' do
    it 'creates a valid cryptocurrency asset' do
      crypto_asset = build(:cryptocurrency_asset)
      expect(crypto_asset).to be_valid
    end

    it 'associates with cryptocurrency category' do
      crypto_asset = create(:cryptocurrency_asset)
      expect(crypto_asset.category.name).to eq('Cryptocurrency')
    end
  end

  describe 'inherited behavior' do
    let(:crypto_asset) { create(:cryptocurrency_asset) }

    it 'inherits asset validations' do
      crypto_asset.name = nil
      expect(crypto_asset).not_to be_valid
      expect(crypto_asset.errors[:name]).to include("can't be blank")
    end

    it 'inherits asset associations' do
      expect(crypto_asset).to respond_to(:category)
      expect(crypto_asset).to respond_to(:asset_prices)
      expect(crypto_asset).to respond_to(:investment_transactions)
    end

    it 'inherits asset methods' do
      expect(crypto_asset).to respond_to(:latest_price)
      expect(crypto_asset).to respond_to(:sync_price)
    end
  end
end
