# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::ProfitAnalytics', type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:category) { create(:category, name: 'Stocks') }
  let(:asset) { create(:stock_asset, category: category, name: 'AAPL') }

  before do
    create(:asset_price, asset: asset, price: 120.0)
  end

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

  describe 'GET /api/v1/profit_analytics/calculate_profit' do
    context 'when there are transactions' do
      before do
        create_transaction(asset, 'buy', 10, 100, 10, 1)  # Cost=1010
        create_transaction(asset, 'sell', 5, 130, 5, 2)   # Proceeds=645
        get '/api/v1/profit_analytics/calculate_profit', headers: headers, as: :json
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct JSON structure and data' do
        json = JSON.parse(response.body)
        data = json['status']['data']

        # WAC at sale: 1010 / 10 = 101
        # Cost basis: 5 * 101 = 505
        # Realized profit: 645 - 505 = 140
        # Remaining cost: 1010 - 505 = 505
        # Remaining qty: 5
        # Current value: 5 * 120 = 600
        # Unrealized profit: 600 - 505 = 95

        # Portfolio Summary
        summary = data['chart_data']['portfolio_summary']
        expect(summary['total_invested']).to eq(505.0) # Remaining cost
        expect(summary['total_current_value']).to eq(600.0)
        expect(summary['total_profit']).to eq(95.0) # Unrealized
        expect(summary['total_realized_profit']).to eq(140.0)

        # Category Details
        category_detail = data['category_details'].first['Stocks']
        expect(category_detail['invested']).to eq(505.0)
        expect(category_detail['current_value']).to eq(600.0)
        expect(category_detail['profit']).to eq(95.0)
        expect(category_detail['realized_profit']).to eq(140.0)

        # Asset Details
        asset_detail = category_detail['assets'].first
        expect(asset_detail['name']).to eq('AAPL')
        expect(asset_detail['realized_profit']).to eq(140.0)
      end
    end

    context 'when there are no transactions' do
      before do
        get '/api/v1/profit_analytics/calculate_profit', headers: headers, as: :json
      end

      it 'returns an empty but valid structure' do
        json = JSON.parse(response.body)
        data = json['status']['data']
        summary = data['chart_data']['portfolio_summary']

        expect(summary['total_invested']).to eq(0.0)
        expect(summary['total_realized_profit']).to eq(0.0)
        expect(data['category_details']).to be_empty
      end
    end
  end

  describe 'GET /api/v1/profit_analytics/calculate_profit_detail' do
    before do
      create_transaction(asset, 'buy', 10, 100, 10, 1)
      create_transaction(asset, 'sell', 5, 130, 5, 2)
      get '/api/v1/profit_analytics/calculate_profit_detail', headers: headers, as: :json
    end

    it 'returns a successful response' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns the detailed transaction rows in the correct structure' do
      json = JSON.parse(response.body)
      detailed_data = json['detailed_data']

      expect(detailed_data).to have_key('Stocks')
      expect(detailed_data['Stocks']).to have_key('AAPL')

      rows = detailed_data['Stocks']['AAPL']
      expect(rows.size).to eq(2)

      # Buy Row
      buy_row = rows.first
      expect(buy_row['transaction_type']).to eq('buy')
      expect(buy_row['invested']).to eq(1010.0)
      expect(buy_row['realized_profit']).to eq(0.0)

      # Sell Row
      sell_row = rows.last
      expect(sell_row['transaction_type']).to eq('sell')
      expect(sell_row['sale_proceeds']).to be_within(0.01).of(645.0)
      expect(sell_row['cost_basis']).to be_within(0.01).of(505.0)
      expect(sell_row['realized_profit']).to be_within(0.01).of(140.0)
    end
  end
end
