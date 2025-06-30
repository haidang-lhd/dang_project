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
require 'rails_helper'

RSpec.describe InvestmentTransaction, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:asset) }
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:unit) }
    it { should validate_presence_of(:nav) }
    it { should validate_numericality_of(:nav).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:fee).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:total_amount).is_greater_than_or_equal_to(0) }
  end

  describe 'factory' do
    it 'creates a valid investment transaction' do
      transaction = build(:investment_transaction)
      expect(transaction).to be_valid
    end

    it 'generates different transaction values' do
      transaction1 = create(:investment_transaction)
      transaction2 = create(:investment_transaction)
      expect(transaction1.quantity).not_to eq(transaction2.quantity)
    end
  end

  describe 'traits' do
    it 'creates buy transaction' do
      transaction = create(:investment_transaction, :buy_transaction)
      expect(transaction.transaction_type).to eq('buy')
    end

    it 'creates sell transaction' do
      transaction = create(:investment_transaction, :sell_transaction)
      expect(transaction.transaction_type).to eq('sell')
    end

    it 'creates recent transaction' do
      transaction = create(:investment_transaction, :recent)
      expect(transaction.date.to_date).to be_within(1.day).of(1.week.ago.to_date)
    end

    it 'creates old transaction' do
      transaction = create(:investment_transaction, :old)
      expect(transaction.date.to_date).to be_within(1.day).of(1.year.ago.to_date)
    end

    it 'creates high value transaction' do
      transaction = create(:investment_transaction, :high_value)
      expect(transaction.quantity).to eq(1000)
      expect(transaction.nav).to eq(50.0)
      expect(transaction.total_amount).to eq(50_000.0)
    end

    it 'creates low value transaction' do
      transaction = create(:investment_transaction, :low_value)
      expect(transaction.quantity).to eq(10)
      expect(transaction.nav).to eq(5.0)
      expect(transaction.total_amount).to eq(50.0)
    end
  end

  describe 'validations' do
    it 'requires quantity to be non-negative' do
      transaction = build(:investment_transaction, quantity: -1)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:quantity]).to include('must be greater than or equal to 0')
    end

    it 'requires nav to be non-negative' do
      transaction = build(:investment_transaction, nav: -1)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:nav]).to include('must be greater than or equal to 0')
    end

    it 'allows nil fee' do
      transaction = build(:investment_transaction, fee: nil)
      expect(transaction).to be_valid
    end

    it 'allows nil total_amount' do
      transaction = build(:investment_transaction, total_amount: nil)
      expect(transaction).to be_valid
    end

    it 'requires fee to be non-negative when present' do
      transaction = build(:investment_transaction, fee: -1)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:fee]).to include('must be greater than or equal to 0')
    end

    it 'requires total_amount to be non-negative when present' do
      transaction = build(:investment_transaction, total_amount: -1)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:total_amount]).to include('must be greater than or equal to 0')
    end
  end

  describe 'decimal precision' do
    it 'stores decimal values with correct precision' do
      transaction = create(:investment_transaction,
                           quantity: 123.4567,
                           nav: 45.6789,
                           fee: 12.34,
                           total_amount: 5678.90)

      transaction.reload
      expect(transaction.quantity).to eq(123.4567)
      expect(transaction.nav).to eq(45.6789)
      expect(transaction.fee).to eq(12.34)
      expect(transaction.total_amount).to eq(5678.90)
    end
  end

  describe 'associations' do
    let(:transaction) { create(:investment_transaction) }

    it 'has associated user' do
      expect(transaction.user).to be_present
      expect(transaction.user).to be_a(User)
    end

    it 'has associated asset' do
      expect(transaction.asset).to be_present
      expect(transaction.asset).to be_a(Asset)
    end
  end
end
