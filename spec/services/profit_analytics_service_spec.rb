# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProfitAnalyticsService do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }
  let(:category) { create(:category, name: 'Stocks') }
  let(:asset) { create(:stock_asset, category: category, name: 'VIC') }

  describe '#initialize' do
    it 'sets the user' do
      expect(service.user).to eq(user)
    end
  end

  describe '#calculate_profit' do
    context 'with no transactions' do
      it 'returns empty data structure' do
        result = service.calculate_profit

        expect(result[:category_details]).to eq({})
        expect(result[:chart_data][:categories]).to eq([])
        expect(result[:chart_data][:portfolio_summary][:total_invested]).to eq(0.0)
        expect(result[:chart_data][:portfolio_summary][:total_current_value]).to eq(0.0)
        expect(result[:chart_data][:portfolio_summary][:total_profit]).to eq(0.0)
        expect(result[:chart_data][:portfolio_summary][:total_profit_percentage]).to eq(0.0)
      end
    end

    context 'with transactions' do
      before do
        # Create asset price first
        create(:asset_price, asset: asset, price: 60.0, synced_at: Time.current)

        create(:investment_transaction,
               user: user,
               asset: asset,
               quantity: 100,
               nav: 50.0,
               transaction_type: 'buy')

        create(:investment_transaction,
               user: user,
               asset: asset,
               quantity: 50,
               nav: 40.0,
               transaction_type: 'buy')
      end

      it 'calculates profit correctly' do
        result = service.calculate_profit

        # Total invested: (100 * 50) + (50 * 40) = 5000 + 2000 = 7000
        # Total quantity: 100 + 50 = 150
        # Current value: 150 * 60 = 9000
        # Profit: 9000 - 7000 = 2000
        # Profit percentage: (2000 / 7000) * 100 = 28.57%

        portfolio_summary = result[:chart_data][:portfolio_summary]
        expect(portfolio_summary[:total_invested]).to eq(7000.0)
        expect(portfolio_summary[:total_current_value]).to eq(9000.0)
        expect(portfolio_summary[:total_profit]).to eq(2000.0)
        expect(portfolio_summary[:total_profit_percentage]).to eq(28.57)
      end

      it 'groups data by category correctly' do
        result = service.calculate_profit

        expect(result[:category_details]).to have_key('Stocks')
        expect(result[:category_details]['Stocks'][:invested]).to eq(7000.0)
        expect(result[:category_details]['Stocks'][:current_value]).to eq(9000.0)
        expect(result[:category_details]['Stocks'][:profit]).to eq(2000.0)
        expect(result[:category_details]['Stocks'][:profit_percentage]).to eq(28.57)
      end

      it 'includes asset details' do
        result = service.calculate_profit

        assets = result[:category_details]['Stocks'][:assets]
        expect(assets.length).to eq(1)

        asset_data = assets.first
        expect(asset_data[:id]).to eq(asset.id)
        expect(asset_data[:name]).to eq('VIC')
        expect(asset_data[:invested]).to eq(7000.0)
        expect(asset_data[:current_value]).to eq(9000.0)
        expect(asset_data[:profit]).to eq(2000.0)
        expect(asset_data[:profit_percentage]).to eq(28.57)
        expect(asset_data[:quantity]).to eq(150.0)
        expect(asset_data[:current_price]).to eq(60.0)
      end

      it 'formats chart data correctly' do
        result = service.calculate_profit

        categories = result[:chart_data][:categories]
        expect(categories.length).to eq(1)

        category_data = categories.first
        expect(category_data[:label]).to eq('Stocks')
        expect(category_data[:invested]).to eq(7000.0)
        expect(category_data[:current_value]).to eq(9000.0)
        expect(category_data[:profit]).to eq(2000.0)
        expect(category_data[:profit_percentage]).to eq(28.57)
      end
    end

    context 'with multiple categories' do
      let(:crypto_category) { create(:category, name: 'Cryptocurrency') }
      let(:crypto_asset) { create(:cryptocurrency_asset, category: crypto_category, name: 'BTC') }

      before do
        # Create asset prices
        create(:asset_price, asset: asset, price: 60.0, synced_at: Time.current)
        create(:asset_price, asset: crypto_asset, price: 50_000.0, synced_at: Time.current)

        # Stock transaction
        create(:investment_transaction,
               user: user,
               asset: asset,
               quantity: 100,
               nav: 50.0,
               transaction_type: 'buy')

        # Crypto transaction
        create(:investment_transaction,
               user: user,
               asset: crypto_asset,
               quantity: 1,
               nav: 40_000.0,
               transaction_type: 'buy')
      end

      it 'calculates totals across all categories' do
        result = service.calculate_profit

        # Stock: 100 * 50 = 5000 invested, 100 * 60 = 6000 current
        # Crypto: 1 * 40000 = 40000 invested, 1 * 50000 = 50000 current
        # Total: 45000 invested, 56000 current, 11000 profit

        portfolio_summary = result[:chart_data][:portfolio_summary]
        expect(portfolio_summary[:total_invested]).to eq(45_000.0)
        expect(portfolio_summary[:total_current_value]).to eq(56_000.0)
        expect(portfolio_summary[:total_profit]).to eq(11_000.0)
        expect(portfolio_summary[:total_profit_percentage]).to eq(24.44)
      end

      it 'separates categories correctly' do
        result = service.calculate_profit

        expect(result[:category_details]).to have_key('Stocks')
        expect(result[:category_details]).to have_key('Cryptocurrency')
        expect(result[:chart_data][:categories].length).to eq(2)
      end
    end

    context 'with sell transactions' do
      before do
        create(:asset_price, asset: asset, price: 60.0, synced_at: Time.current)

        create(:investment_transaction,
               user: user,
               asset: asset,
               quantity: 100,
               nav: 50.0,
               transaction_type: 'buy')

        create(:investment_transaction,
               user: user,
               asset: asset,
               quantity: 40,
               nav: 70.0,
               transaction_type: 'sell')
      end

      it 'deducts sold quantity and updates profit' do
        result = service.calculate_profit
        asset_data = result[:category_details]['Stocks'][:assets].first

        expect(asset_data[:quantity]).to eq(60.0)
        expect(asset_data[:invested]).to eq(2200.0)
        expect(asset_data[:current_value]).to eq(3600.0)
        expect(asset_data[:profit]).to eq(1400.0)
        expect(asset_data[:profit_percentage]).to eq(63.64)
      end
    end

    context 'with loss scenario' do
      before do
        # Create asset price (lower than purchase price)
        create(:asset_price, asset: asset, price: 60.0, synced_at: Time.current)

        create(:investment_transaction,
               user: user,
               asset: asset,
               quantity: 100,
               nav: 80.0,
               transaction_type: 'buy')
      end

      it 'handles negative profit correctly' do
        result = service.calculate_profit

        # Invested: 100 * 80 = 8000
        # Current: 100 * 60 = 6000
        # Loss: 6000 - 8000 = -2000
        # Loss percentage: (-2000 / 8000) * 100 = -25%

        portfolio_summary = result[:chart_data][:portfolio_summary]
        expect(portfolio_summary[:total_invested]).to eq(8000.0)
        expect(portfolio_summary[:total_current_value]).to eq(6000.0)
        expect(portfolio_summary[:total_profit]).to eq(-2000.0)
        expect(portfolio_summary[:total_profit_percentage]).to eq(-25.0)
      end
    end

    context 'with zero invested amount' do
      let(:zero_asset) { create(:stock_asset, category: category, name: 'ZERO') }

      before do
        create(:asset_price, asset: zero_asset, price: 100.0, synced_at: Time.current)

        create(:investment_transaction,
               user: user,
               asset: zero_asset,
               quantity: 0,
               nav: 0,
               transaction_type: 'buy')
      end

      it 'handles zero division safely' do
        result = service.calculate_profit

        expect(result[:category_details]['Stocks'][:profit_percentage]).to eq(0.0)
        expect(result[:chart_data][:portfolio_summary][:total_profit_percentage]).to eq(0.0)
      end
    end
  end
end
