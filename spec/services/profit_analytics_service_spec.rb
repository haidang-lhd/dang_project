# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfitAnalyticsService do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }
  let(:category) { create(:category, name: 'Stocks') }
  let(:asset) { create(:stock_asset, category: category, name: 'AAPL') }

  before do
    create(:asset_price, asset: asset, price: 150.0)
  end

  # Helper to create transactions with consistent dates
  def create_transaction(asset, type, quantity, price, fee = 0.0, date_offset = 0)
    create(:investment_transaction,
           user: user,
           asset: asset,
           transaction_type: type,
           quantity: quantity,
           nav: price,
           fee: fee,
           date: Time.current + date_offset.days,
           created_at: Time.current + date_offset.days)
  end

  describe '#calculate_profit' do
    context 'with no transactions' do
      it 'returns an empty but valid structure' do
        result = service.calculate_profit
        expect(result[:category_details]).to be_empty
        summary = result[:chart_data][:portfolio_summary]
        expect(summary[:total_invested]).to eq(0.0)
        expect(summary[:total_current_value]).to eq(0.0)
        expect(summary[:total_profit]).to eq(0.0)
        expect(summary[:total_realized_profit]).to eq(0.0)
        expect(summary[:total_profit_percentage]).to eq(0.0)
      end
    end

    context 'with basic buy transactions' do
      before do
        create_transaction(asset, 'buy', 10, 100) # Cost = 1000
      end

      it 'calculates metrics for a single buy' do
        result = service.calculate_profit
        summary = result[:chart_data][:portfolio_summary]

        # Remaining cost = 1000, Current value = 10 * 150 = 1500
        # Unrealized profit = 500
        expect(summary[:total_invested]).to eq(1000.0)
        expect(summary[:total_current_value]).to eq(1500.0)
        expect(summary[:total_profit]).to eq(500.0) # Unrealized
        expect(summary[:total_realized_profit]).to eq(0.0)
        expect(summary[:total_profit_percentage]).to be_within(0.01).of(50.0)
      end
    end

    context 'with buy and sell transactions (WAC)' do
      before do
        # 1. Buy 10 at $100 -> held: 10, cost: 1000, wac: 100
        create_transaction(asset, 'buy', 10, 100, 0, 1)
        # 2. Buy 10 at $120 -> held: 20, cost: 1000 + 1200 = 2200, wac: 110
        create_transaction(asset, 'buy', 10, 120, 0, 2)
        # 3. Sell 15 at $140 -> wac: 110
        create_transaction(asset, 'sell', 15, 140, 0, 3)
      end

      it 'calculates profit correctly using WAC' do
        result = service.calculate_profit

        # After sell:
        # Cost basis for sale: 15 * 110 = 1650
        # Sale proceeds: 15 * 140 = 2100
        # Realized profit: 2100 - 1650 = 450
        #
        # Remaining position:
        # Held qty: 20 - 15 = 5
        # Remaining cost: 2200 - 1650 = 550
        # Current value: 5 * 150 = 750
        # Unrealized profit: 750 - 550 = 200

        summary = result[:chart_data][:portfolio_summary]
        expect(summary[:total_invested]).to eq(550.0)         # Remaining cost
        expect(summary[:total_current_value]).to eq(750.0)    # Value of remaining shares
        expect(summary[:total_profit]).to eq(200.0)           # Unrealized profit
        expect(summary[:total_realized_profit]).to eq(450.0)
        # Total profit % = unrealized / remaining_cost
        expect(summary[:total_profit_percentage]).to be_within(0.01).of(36.36)

        category_detail = result[:category_details]['Stocks']
        expect(category_detail[:invested]).to eq(550.0)
        expect(category_detail[:current_value]).to eq(750.0)
        expect(category_detail[:profit]).to eq(200.0)
        expect(category_detail[:realized_profit]).to eq(450.0)
      end
    end

    context 'with full liquidation' do
      before do
        create_transaction(asset, 'buy', 10, 100, 10, 1) # Cost = 1010
        create_transaction(asset, 'sell', 10, 120, 5, 2) # Proceeds = 1195
      end

      it 'handles zero remaining quantity and cost' do
        result = service.calculate_profit

        # Realized profit = 1195 - 1010 = 185
        # Remaining cost/qty/value should be zero
        summary = result[:chart_data][:portfolio_summary]
        expect(summary[:total_invested]).to eq(0.0)
        expect(summary[:total_current_value]).to eq(0.0)
        expect(summary[:total_profit]).to eq(0.0) # No unrealized profit
        expect(summary[:total_realized_profit]).to eq(185.0)
        expect(summary[:total_profit_percentage]).to eq(0.0)
      end
    end

    context 'with multiple categories' do
      let(:crypto_cat) { create(:category, name: 'Crypto') }
      let(:btc) { create(:cryptocurrency_asset, category: crypto_cat, name: 'BTC') }

      before do
        create(:asset_price, asset: btc, price: 60_000)
        # Stock: Buy 10 AAPL @ 100
        create_transaction(asset, 'buy', 10, 100, 0, 1)
        # Crypto: Buy 0.1 BTC @ 50000
        create_transaction(btc, 'buy', 0.1, 50_000, 0, 1)
      end

      it 'aggregates totals and separates categories correctly' do
        result = service.calculate_profit

        # Stock: invested=1000, value=1500, unrealized=500
        # Crypto: invested=5000, value=6000, unrealized=1000
        summary = result[:chart_data][:portfolio_summary]
        expect(summary[:total_invested]).to eq(6000.0)
        expect(summary[:total_current_value]).to eq(7500.0)
        expect(summary[:total_profit]).to eq(1500.0)
        expect(summary[:total_realized_profit]).to eq(0.0)

        # Check category separation
        expect(result[:category_details].keys).to contain_exactly('Stocks', 'Crypto')
        expect(result[:category_details]['Stocks'][:invested]).to eq(1000.0)
        expect(result[:category_details]['Crypto'][:invested]).to eq(5000.0)

        # Check chart data for current value percentages
        stock_chart = result[:chart_data][:categories].find { |c| c[:label] == 'Stocks' }
        crypto_chart = result[:chart_data][:categories].find { |c| c[:label] == 'Crypto' }

        # Total value = 7500. Stock value = 1500 (20%). Crypto value = 6000 (80%)
        expect(stock_chart[:current_value_percentage]).to be_within(0.01).of(20.0)
        expect(crypto_chart[:current_value_percentage]).to be_within(0.01).of(80.0)
      end
    end
  end

  describe '#calculate_profit_detail' do
    context 'with buy and sell transactions' do
      let!(:buy1) { create_transaction(asset, 'buy', 10, 100, 10, 1) } # Cost=1010, WAC=101
      let!(:buy2) { create_transaction(asset, 'buy', 5, 110, 5, 2) } # Cost=555, TotalCost=1565, TotalQty=15, WAC=104.33
      let!(:sell1) { create_transaction(asset, 'sell', 8, 130, 8, 3) } # Proceeds=1032

      it 'returns detailed transaction rows with correct WAC calculations' do
        result = service.calculate_profit_detail
        rows = result[:detailed_data]['Stocks']['AAPL']

        expect(rows.size).to eq(3)

        # --- Row 1: First Buy ---
        buy1_row = rows[0]
        expect(buy1_row[:transaction_type]).to eq('buy')
        expect(buy1_row[:invested]).to eq(1010.0) # 10*100 + 10
        expect(buy1_row[:current_value]).to eq(1500.0) # 10 * 150
        expect(buy1_row[:profit]).to eq(490.0) # Unrealized
        expect(buy1_row[:realized_profit]).to eq(0.0)
        expect(buy1_row[:cost_basis]).to eq(0.0)

        # --- Row 2: Second Buy ---
        buy2_row = rows[1]
        expect(buy2_row[:transaction_type]).to eq('buy')
        expect(buy2_row[:invested]).to eq(555.0) # 5*110 + 5
        expect(buy2_row[:current_value]).to eq(750.0) # 5 * 150
        expect(buy2_row[:profit]).to eq(195.0) # Unrealized
        expect(buy2_row[:realized_profit]).to eq(0.0)

        # --- Row 3: The Sell ---
        # WAC at time of sale: (1010 + 555) / 15 = 104.333
        # Cost basis for sale: 8 * 104.333 = 834.67
        # Proceeds: 8 * 130 - 8 = 1032
        # Realized profit: 1032 - 834.67 = 197.33
        sell1_row = rows[2]
        expect(sell1_row[:transaction_type]).to eq('sell')
        expect(sell1_row[:sale_proceeds]).to be_within(0.01).of(1032.0)
        expect(sell1_row[:cost_basis]).to be_within(0.01).of(834.67)
        expect(sell1_row[:realized_profit]).to be_within(0.01).of(197.33)
        # For sells, `invested`, `current_value`, and `profit` mirror cost_basis, proceeds, and realized
        expect(sell1_row[:invested]).to eq(sell1_row[:cost_basis])
        expect(sell1_row[:current_value]).to eq(sell1_row[:sale_proceeds])
        expect(sell1_row[:profit]).to eq(sell1_row[:realized_profit])
      end
    end

    context 'when a sell would exceed holdings' do
      it 'raises an error' do
        create_transaction(asset, 'buy', 5, 100)
        create_transaction(asset, 'sell', 10, 120) # Oversell

        expect { service.calculate_profit_detail }.to raise_error(StandardError, /Sell exceeds holdings/)
      end
    end
  end
end
