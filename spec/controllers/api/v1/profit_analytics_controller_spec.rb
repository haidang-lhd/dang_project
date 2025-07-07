# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProfitAnalyticsController, type: :controller do
  let(:user) { create(:user) }
  let(:category) { create(:category, name: 'Stocks') }
  let(:asset) { create(:stock_asset, category: category, name: 'VIC') }
  let(:valid_headers) do
    token = JWT.encode({ sub: user.id }, Rails.application.secret_key_base)
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'GET #calculate_profit' do
    context 'when authenticated' do
      before do
        request.headers.merge!(valid_headers)

        # Create some test data
        create(:investment_transaction,
               user: user,
               asset: asset,
               quantity: 100,
               nav: 50.0,
               transaction_type: 'buy')

        # Create asset price
        create(:asset_price, asset: asset, price: 60.0, synced_at: Time.current)
      end

      it 'returns profit calculation successfully' do
        get :calculate_profit
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Profit calculation completed successfully')

        chart_data = json_response['status']['data']['chart_data']
        expect(chart_data['categories']).to be_an(Array)
        expect(chart_data['portfolio_summary']).to include(
          'total_invested',
          'total_current_value',
          'total_profit',
          'total_profit_percentage'
        )
      end

      it 'calculates profit correctly' do
        get :calculate_profit
        json_response = JSON.parse(response.body)

        portfolio_summary = json_response['status']['data']['chart_data']['portfolio_summary']
        expect(portfolio_summary['total_invested']).to eq('5000.0') # 100 * 50
        expect(portfolio_summary['total_current_value']).to eq('6000.0') # 100 * 60
        expect(portfolio_summary['total_profit']).to eq('1000.0') # 6000 - 5000
        expect(portfolio_summary['total_profit_percentage']).to eq('20.0') # (1000/5000) * 100
      end

      it 'groups data by category correctly' do
        get :calculate_profit
        json_response = JSON.parse(response.body)

        categories = json_response['status']['data']['chart_data']['categories']
        expect(categories.length).to eq(1)
        expect(categories.first['label']).to eq('Stocks')
        expect(categories.first['invested']).to eq('5000.0')
        expect(categories.first['current_value']).to eq('6000.0')
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        get :calculate_profit
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
