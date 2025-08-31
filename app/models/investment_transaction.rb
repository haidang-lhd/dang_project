# frozen_string_literal: true

# == Schema Information
#
# Table name: investment_transactions
#
#  id               :bigint           not null, primary key
#  date             :date             not null
#  fee              :decimal(15, 2)
#  nav              :decimal(15, 4)   not null
#  quantity         :decimal(15, 4)   not null
#  total_amount     :decimal(15, 2)
#  transaction_type :string           not null
#  unit             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  asset_id         :bigint           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_investment_transactions_on_asset_id  (asset_id)
#  index_investment_transactions_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (asset_id => assets.id)
#  fk_rails_...  (user_id => users.id)
#
class InvestmentTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :asset

  # Define transaction types as enum with string values
  enum :transaction_type, { buy: 'buy', sell: 'sell' }

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unit, presence: true
  validates :nav, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fee, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :transaction_type, presence: true
end
