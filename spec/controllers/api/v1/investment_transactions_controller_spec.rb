# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::InvestmentTransactionsController, type: :controller do
  render_views # This enables actual view rendering in controller specs

  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:category) { create(:category, name: 'Stocks') }
  let!(:asset) { create(:asset, name: 'Apple Inc', category: category, type: 'StockAsset') }
  let!(:transaction1) { create(:investment_transaction, user: user, asset: asset) }
  let!(:transaction2) { create(:investment_transaction, user: user, asset: asset) }
  let!(:other_user_transaction) { create(:investment_transaction, user: other_user, asset: asset) }

  let(:auth_headers) { { 'Authorization' => "Bearer #{generate_jwt_token(user)}" } }

  describe 'GET #index' do
    context 'with authentication' do
      before do
        request.headers.merge!(auth_headers)
        get :index, format: :json
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns only current user transactions ordered by date descending' do
        json_response = JSON.parse(response.body)
        expect(json_response.length).to eq(2)
        json_response.each do |transaction|
          expect(transaction['user']['id']).to eq(user.id)
        end
      end

      it 'includes transaction attributes with user and asset information' do
        json_response = JSON.parse(response.body)
        transaction = json_response.first

        expect(transaction).to include('id', 'transaction_type', 'quantity', 'nav', 'total_amount', 'fee', 'unit', 'date')
        expect(transaction['user']).to include('id', 'email')
        expect(transaction['asset']).to include('id', 'name', 'type')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized status' do
        get :index, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    context 'with authentication' do
      before do
        request.headers.merge!(auth_headers)
        get :show, params: { id: transaction1.id }, format: :json
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the specific transaction with full details' do
        json_response = JSON.parse(response.body)

        expect(json_response['id']).to eq(transaction1.id)
        expect(json_response['asset']['category']).to include('id', 'name')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized status' do
        get :show, params: { id: transaction1.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'accessing other user transaction' do
      before do
        request.headers.merge!(auth_headers)
      end

      it 'returns not found status' do
        get :show, params: { id: other_user_transaction.id }, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        asset_id: asset.id,
        transaction_type: 'buy',
        quantity: 100.0,
        nav: 150.50,
        total_amount: 15_050.0,
        fee: 50.0,
        unit: 'shares',
        date: Date.current,
      }
    end

    let(:invalid_attributes) do
      {
        asset_id: asset.id,
        transaction_type: 'buy',
      }
    end

    context 'with valid parameters and authentication' do
      before do
        request.headers.merge!(auth_headers)
      end

      it 'creates a new investment transaction' do
        expect do
          post :create, params: { investment_transaction: valid_attributes }, format: :json
        end.to change(InvestmentTransaction, :count).by(1)
      end

      it 'returns created status' do
        post :create, params: { investment_transaction: valid_attributes }, format: :json
        expect(response).to have_http_status(:created)
      end

      it 'returns the created transaction' do
        post :create, params: { investment_transaction: valid_attributes }, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response['transaction_type']).to eq('buy')
        expect(json_response['quantity']).to eq('100.0')
      end

      it 'associates transaction with current user' do
        post :create, params: { investment_transaction: valid_attributes }, format: :json
        json_response = JSON.parse(response.body)
        expect(json_response['user']['id']).to eq(user.id)
      end
    end

    context 'with invalid parameters and authentication' do
      before do
        request.headers.merge!(auth_headers)
      end

      it 'does not create a new investment transaction' do
        expect do
          post :create, params: { investment_transaction: invalid_attributes }, format: :json
        end.not_to change(InvestmentTransaction, :count)
      end

      it 'returns unprocessable entity status' do
        post :create, params: { investment_transaction: invalid_attributes }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        post :create, params: { investment_transaction: invalid_attributes }, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response).to have_key('errors')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized status' do
        post :create, params: { investment_transaction: valid_attributes }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH/PUT #update' do
    let(:new_attributes) do
      {
        quantity: 200.0,
        nav: 160.75,
      }
    end

    context 'with valid parameters and authentication' do
      before do
        request.headers.merge!(auth_headers)
      end

      it 'updates the investment transaction' do
        patch :update, params: { id: transaction1.id, investment_transaction: new_attributes }, format: :json
        transaction1.reload

        expect(transaction1.quantity).to eq(200.0)
        expect(transaction1.nav).to eq(160.75)
      end

      it 'returns success status' do
        patch :update, params: { id: transaction1.id, investment_transaction: new_attributes }, format: :json
        expect(response).to have_http_status(:success)
      end

      it 'returns the updated transaction' do
        patch :update, params: { id: transaction1.id, investment_transaction: new_attributes }, format: :json
        json_response = JSON.parse(response.body)

        expect(json_response['quantity']).to eq('200.0')
        expect(json_response['nav']).to eq('160.75')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized status' do
        patch :update, params: { id: transaction1.id, investment_transaction: new_attributes }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with authentication' do
      before do
        request.headers.merge!(auth_headers)
      end

      it 'destroys the investment transaction' do
        expect do
          delete :destroy, params: { id: transaction1.id }, format: :json
        end.to change(InvestmentTransaction, :count).by(-1)
      end

      it 'returns no content status' do
        delete :destroy, params: { id: transaction1.id }, format: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized status' do
        delete :destroy, params: { id: transaction1.id }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
