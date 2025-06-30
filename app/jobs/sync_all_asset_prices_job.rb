# frozen_string_literal: true

class SyncAllAssetPricesJob < ApplicationJob
  queue_as :default

  def perform
    Asset.find_each(&:sync_price)
  end
end
