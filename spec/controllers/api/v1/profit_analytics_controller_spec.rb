# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ProfitAnalyticsController, type: :controller do
  let(:user) { create(:user) }
  let(:mock_service) { instance_double(ProfitAnalyticsService) }
  let(:mock_profit_data) do
    {
      category_details: {
        'Stocks' => {
          invested: 10_000.0,
          current_value: 12_000.0,
          profit: 2000.0,
          profit_percentage: 20.0,
          assets: [
            {
              id: 1,
              name: 'Apple Inc.',
              invested: 5000.0,
              current_value: 6000.0,
              profit: 1000.0,
              profit_percentage: 20.0,
              quantity: 100.0,
              current_price: 60.0,
            },
            {
              id: 2,
              name: 'Microsoft Corp.',
              invested: 5000.0,
              current_value: 6000.0,
              profit: 1000.0,
              profit_percentage: 20.0,
              quantity: 50.0,
              current_price: 120.0,
            },
          ],
        },
        'Bonds' => {
          invested: 5000.0,
          current_value: 5250.0,
          profit: 250.0,
          profit_percentage: 5.0,
          assets: [
            {
              id: 3,
              name: 'US Treasury Bond',
              invested: 5000.0,
              current_value: 5250.0,
              profit: 250.0,
              profit_percentage: 5.0,
              quantity: 50.0,
              current_price: 105.0,
            },
          ],
        },
      },
      chart_data: {
        categories: [
          {
            label: 'Stocks',
            invested: 10_000.0,
            current_value: 12_000.0,
            profit: 2000.0,
            profit_percentage: 20.0,
          },
          {
            label: 'Bonds',
            invested: 5000.0,
            current_value: 5250.0,
            profit: 250.0,
            profit_percentage: 5.0,
          },
        ],
        portfolio_summary: {
          total_invested: 15_000.0,
          total_current_value: 17_250.0,
          total_profit: 2250.0,
          total_profit_percentage: 15.0,
        },
      },
    }
  end

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe 'GET #calculate_profit' do
    context 'when user is authenticated' do
      before do
        allow(ProfitAnalyticsService).to receive(:new).with(user).and_return(mock_service)
        allow(mock_service).to receive(:calculate_profit).and_return(mock_profit_data)
      end

      it 'returns http success' do
        get :calculate_profit, format: :json
        expect(response).to have_http_status(:success)
      end

      it 'creates a ProfitAnalyticsService instance with current user' do
        get :calculate_profit, format: :json
        expect(ProfitAnalyticsService).to have_received(:new).with(user)
      end

      it 'calls calculate_profit on the service' do
        get :calculate_profit, format: :json
        expect(mock_service).to have_received(:calculate_profit)
      end

      it 'assigns the result to @result' do
        get :calculate_profit, format: :json
        expect(assigns(:result)).to eq(mock_profit_data)
      end

      it 'renders the calculate_profit template' do
        get :calculate_profit, format: :json
        expect(response).to render_template(:calculate_profit)
      end

      it 'returns the expected response status and content type' do
        get :calculate_profit, format: :json
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('application/json')
      end
    end

    context 'when user is not authenticated' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
        allow(controller).to receive(:authenticate_user!).and_raise(StandardError.new('Authentication required'))
      end

      it 'raises an authentication error' do
        expect { get :calculate_profit, format: :json }.to raise_error(StandardError, 'Authentication required')
      end
    end

    context 'when service raises an error' do
      before do
        allow(ProfitAnalyticsService).to receive(:new).with(user).and_return(mock_service)
        allow(mock_service).to receive(:calculate_profit).and_raise(StandardError.new('Service error'))
      end

      it 'propagates the service error' do
        expect { get :calculate_profit, format: :json }.to raise_error(StandardError, 'Service error')
      end
    end

    context 'when service returns empty data' do
      let(:empty_profit_data) do
        {
          category_details: {},
          chart_data: {
            categories: [],
            portfolio_summary: {
              total_invested: 0.0,
              total_current_value: 0.0,
              total_profit: 0.0,
              total_profit_percentage: 0.0,
            },
          },
        }
      end

      before do
        allow(ProfitAnalyticsService).to receive(:new).with(user).and_return(mock_service)
        allow(mock_service).to receive(:calculate_profit).and_return(empty_profit_data)
      end

      it 'returns success with empty data' do
        get :calculate_profit, format: :json
        expect(response).to have_http_status(:success)
      end

      it 'assigns empty result data' do
        get :calculate_profit, format: :json
        expect(assigns(:result)).to eq(empty_profit_data)
      end

      it 'renders the calculate_profit template' do
        get :calculate_profit, format: :json
        expect(response).to render_template(:calculate_profit)
      end
    end
  end
end
