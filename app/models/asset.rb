# == Schema Information
#
# Table name: assets
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_assets_on_category_id  (category_id)
#  index_assets_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#  fk_rails_...  (user_id => users.id)
#
class Asset < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :asset_labels
  has_many :labels, through: :asset_labels
  has_many :asset_prices
  has_many :investment_transactions

  validates :name, presence: true
  validates :category, presence: true

  def latest_price
    asset_prices.order(synced_at: :desc).first
  end
end
