require 'rails_helper'

RSpec.describe Asset, type: :model do
  describe '#manual_set_price' do
    let(:category) { Category.create!(name: 'Test Category') }
    let(:asset) { Asset.create!(name: 'Test Asset', category: category) }

    it 'creates a new asset_price with the given price' do
      expect {
        asset.manual_set_price(123.45)
      }.to change { asset.asset_prices.count }.by(1)

      price_record = asset.asset_prices.order(synced_at: :desc).first
      expect(price_record.price).to eq(123.45)
      expect(price_record.synced_at).to be_within(1.second).of(Time.current)
    end
  end
end

