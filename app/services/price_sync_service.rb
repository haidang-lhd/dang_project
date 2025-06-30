# frozen_string_literal: true

class PriceSyncService
  # Syncs prices for all assets of a user
  def self.sync_all_for_user(user)
    user.assets.find_each do |asset|
      # Mock price for demonstration
      price = rand(10.0..1000.0).round(2)
      AssetPrice.create!(asset: asset, price: price, synced_at: Time.current)
    end
  end
end
