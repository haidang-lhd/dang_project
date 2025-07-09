# frozen_string_literal: true

class AssetPriceChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'asset_price_updates'
    Rails.logger.info 'User subscribed to asset_price_updates channel'
  end

  def unsubscribed
    Rails.logger.info 'User unsubscribed from asset_price_updates channel'
    # Any cleanup needed when channel is unsubscribed
  end
end
