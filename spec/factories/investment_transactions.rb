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
FactoryBot.define do
  factory :investment_transaction do
    date { Faker::Date.between(from: 1.year.ago, to: Date.current) }
    quantity { Faker::Number.decimal(l_digits: 3, r_digits: 4) }
    unit { %w[share gram piece].sample }
    nav { Faker::Number.decimal(l_digits: 4, r_digits: 4) }
    fee { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    total_amount { Faker::Number.decimal(l_digits: 5, r_digits: 2) }
    transaction_type { %w[buy sell].sample }
    association :user
    association :asset

    trait :buy_transaction do
      transaction_type { "buy" }
    end

    trait :sell_transaction do
      transaction_type { "sell" }
    end

    trait :recent do
      date { 1.week.ago }
    end

    trait :old do
      date { 1.year.ago }
    end

    trait :high_value do
      quantity { 1000 }
      nav { 50.0 }
      total_amount { 50000.0 }
    end

    trait :low_value do
      quantity { 10 }
      nav { 5.0 }
      total_amount { 50.0 }
    end
  end
end
