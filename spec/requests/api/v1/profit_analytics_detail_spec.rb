# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ProfitAnalytics Detailed Data', type: :request do
  let(:user) { create(:user) }
  let(:category) { create(:category, name: 'Stocks') }
  let(:asset) { create(:stock_asset, category: category, name: 'AAPL') }

  before do
    # Set up JWT authentication
    @auth_headers = auth_headers_for(user)

    # Create current price
    create(:asset_price, asset: asset, price: 60.0, synced_at: Time.current)

    # Create some transactions
    create(:investment_transaction,
           user: user,
           asset: asset,
           quantity: 100,
           nav: 50.0,
           transaction_type: 'buy',
           created_at: 1.month.ago)

    create(:investment_transaction,
           user: user,
           asset: asset,
           quantity: 50,
           nav: 70.0,
           transaction_type: 'sell',
           created_at: 1.week.ago)
  end

  describe 'GET /api/v1/profit_analytics/calculate_profit_detail' do
    it 'returns detailed transaction rows with WAC metrics' do
      get '/api/v1/profit_analytics/calculate_profit_detail', headers: @auth_headers
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json['detailed_data']).to be_present
      expect(json['detailed_data']['Stocks']).to be_present
      expect(json['detailed_data']['Stocks']['AAPL']).to be_present

      rows = json['detailed_data']['Stocks']['AAPL']
      expect(rows.length).to eq(2)

      # Buy transaction
      buy = rows.find { |r| r['transaction_type'] == 'buy' }
      expect(buy['transaction_type']).to eq('buy')
      expect(buy['quantity']).to eq(100.0)
      expect(buy['nav']).to eq(50.0)
      expect(buy['current_value']).to eq(6000.0) # 100 * 60.0 current price
      expect(buy['sale_proceeds']).to eq(0.0)
      expect(buy['cost_basis']).to eq(0.0)
      expect(buy['realized_profit']).to eq(0.0)
      # Values that include fees - just check they are present and reasonable
      expect(buy['invested']).to be_between(5000.0, 5100.0) # Base price + fee
      expect(buy['profit']).to be_between(900.0, 1000.0)    # current_value - invested
      expect(buy['profit_percentage']).to be_between(18.0, 20.0) # (profit / invested) * 100

      # Sell transaction
      sell = rows.find { |r| r['transaction_type'] == 'sell' }
      expect(sell['transaction_type']).to eq('sell')
      expect(sell['quantity']).to eq(50.0)
      expect(sell['nav']).to eq(70.0)
      # Values that might include fees
      expect(sell['sale_proceeds']).to be_between(3400.0, 3500.0) # 50 * 70.0 - fee
      expect(sell['realized_profit']).to be_between(800.0, 1000.0) # Reasonable range for the profit
    end
  end
end
