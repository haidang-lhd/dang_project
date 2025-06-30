# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SyncAllAssetPricesJob, type: :job do
  let!(:category) { Category.create!(name: 'Test Category') }
  let!(:asset1) { Asset.create!(name: 'Asset 1', category: category) }
  let!(:asset2) { Asset.create!(name: 'Asset 2', category: category) }

  it 'calls sync_price on all assets' do
    call_count = 0
    allow_any_instance_of(Asset).to receive(:sync_price) { call_count += 1 }
    described_class.perform_now
    expect(call_count).to eq(2)
  end

  it 'creates a new asset_price for each asset' do
    allow_any_instance_of(Asset).to receive(:sync_price) do |asset|
      asset.asset_prices.create!(price: 100, synced_at: Time.current)
    end
    expect do
      described_class.perform_now
    end.to change { AssetPrice.count }.by(2)
  end
end
