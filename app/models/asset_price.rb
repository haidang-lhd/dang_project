# frozen_string_literal: true

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
class AssetPrice < ApplicationRecord
  belongs_to :asset

  validates :price, presence: true
  validates :synced_at, presence: true

  after_create :broadcast_price_update

  private

  def broadcast_price_update
    # Broadcast to all users who might be interested in this asset price update
    Rails.logger.info "Broadcasting asset price update for asset #{asset_id}"

    broadcast_data = {
      asset_price: {
        id: id,
        asset_id: asset_id,
        asset_name: asset.name,
        price: price.to_f,
        synced_at: synced_at.iso8601,
        category: asset.category.name,
      },
      type: 'asset_price_created',
      timestamp: Time.current.iso8601,
    }

    ActionCable.server.broadcast('asset_price_updates', broadcast_data)
    Rails.logger.info "Broadcasted: #{broadcast_data}"
  rescue => e
    Rails.logger.error "Failed to broadcast asset price update: #{e.message}"
  end
end
