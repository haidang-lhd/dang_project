# == Schema Information
#
# Table name: assets
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :bigint           not null
#
# Indexes
#
#  index_assets_on_category_id  (category_id)
#
# Foreign Keys
#
#  fk_rails_...  (category_id => categories.id)
#
class Asset < ApplicationRecord
  VINACAPITAL_FUND = [ "VESAF", "VMEEF", "VEOF", "VDEF" ]
  DRAGON_CAPITAL_FUND = [ "DCDS", "DCDE" ]

  belongs_to :category
  has_many :asset_prices
  has_many :investment_transactions

  validates :name, presence: true
  validates :category, presence: true

  def latest_price
    asset_prices.order(synced_at: :desc).first
  end
end
