class SyncAllAssetPricesJob < ApplicationJob
  queue_as :default

  def perform
    Asset.find_each do |asset|
      asset.sync_price
    end
  end
end
