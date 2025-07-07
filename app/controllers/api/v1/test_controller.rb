# frozen_string_literal: true

class Api::V1::TestController < Api::V1::BaseController
  before_action :authenticate_user!

  def create_test_asset_price
    # Find or create a test asset
    category = Category.first || Category.create!(name: 'Test Category')
    asset = Asset.first || Asset.create!(name: 'Test Asset', category: category, type: 'StockAsset')

    # Create a new asset price with random data to trigger WebSocket
    asset_price = asset.asset_prices.create!(
      price: rand(50.0..200.0).round(2),
      synced_at: Time.current
    )

    render json: {
      status: {
        code: 201,
        message: 'Test asset price created successfully',
        data: {
          asset_price: {
            id: asset_price.id,
            asset_name: asset.name,
            price: asset_price.price,
            synced_at: asset_price.synced_at,
          },
        },
      },
    }, status: :created
  end
end
