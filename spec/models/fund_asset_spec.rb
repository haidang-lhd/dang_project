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

RSpec.describe FundAsset, type: :model do
  describe 'inheritance' do
    it 'inherits from Asset' do
      expect(FundAsset.superclass).to eq(Asset)
    end

    it 'has correct type' do
      fund_asset = create(:fund_asset)
      expect(fund_asset.type).to eq('FundAsset')
    end
  end

  describe 'factory' do
    it 'creates a valid fund asset' do
      fund_asset = build(:fund_asset)
      expect(fund_asset).to be_valid
    end

    it 'associates with investment fund certificates category' do
      fund_asset = create(:fund_asset)
      expect(fund_asset.category.name).to eq('Investment Fund Certificates')
    end
  end

  describe 'traits' do
    it 'creates VESAF fund asset' do
      fund_asset = create(:fund_asset, :vesaf)
      expect(fund_asset.name).to eq('VESAF')
    end

    it 'creates VMEEF fund asset' do
      fund_asset = create(:fund_asset, :vmeef)
      expect(fund_asset.name).to eq('VMEEF')
    end
  end

  describe 'inherited behavior' do
    let(:fund_asset) { create(:fund_asset) }

    it 'inherits asset validations' do
      fund_asset.name = nil
      expect(fund_asset).not_to be_valid
      expect(fund_asset.errors[:name]).to include("can't be blank")
    end

    it 'inherits asset associations' do
      expect(fund_asset).to respond_to(:category)
      expect(fund_asset).to respond_to(:asset_prices)
      expect(fund_asset).to respond_to(:investment_transactions)
    end

    it 'inherits asset methods' do
      expect(fund_asset).to respond_to(:latest_price)
      expect(fund_asset).to respond_to(:sync_price)
    end
  end
end
