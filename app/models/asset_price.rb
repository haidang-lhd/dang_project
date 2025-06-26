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
end
