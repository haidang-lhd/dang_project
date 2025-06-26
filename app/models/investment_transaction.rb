# == Schema Information
#
# Table name: investment_transactions
#
#  id               :bigint           not null, primary key
#  amount           :decimal(, )      not null
#  date             :date             not null
#  transaction_type :string           not null
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
end
