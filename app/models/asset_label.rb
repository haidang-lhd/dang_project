# == Schema Information
#
# Table name: asset_labels
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  asset_id   :bigint           not null
#  label_id   :bigint           not null
#
# Indexes
#
#  index_asset_labels_on_asset_id               (asset_id)
#  index_asset_labels_on_asset_id_and_label_id  (asset_id,label_id) UNIQUE
#  index_asset_labels_on_label_id               (label_id)
#
# Foreign Keys
#
#  fk_rails_...  (asset_id => assets.id)
#  fk_rails_...  (label_id => labels.id)
#
class AssetLabel < ApplicationRecord
  belongs_to :asset
  belongs_to :label
end
