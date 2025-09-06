# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AssetsController, type: :controller do
  render_views # This enables actual view rendering in controller specs

  let!(:user) { create(:user) }
  let!(:category) { create(:category, name: 'Stocks') }
  let!(:asset1) { create(:asset, name: 'Apple Inc', category: category, type: 'StockAsset') }
  let!(:asset2) { create(:asset, name: 'Google Inc', category: category, type: 'StockAsset') }

  let(:auth_headers) { { 'Authorization' => "Bearer #{generate_jwt_token(user)}" } }

  describe 'GET #index' do
    context 'without category filter' do
      before do
        request.headers.merge!(auth_headers)
        get :index, format: :json
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns all assets ordered by name' do
        json_response = JSON.parse(response.body)
        expect(json_response.length).to eq(2)
        expect(json_response.first['name']).to eq('Apple Inc')
        expect(json_response.second['name']).to eq('Google Inc')
      end

      it 'includes asset attributes and category information' do
        json_response = JSON.parse(response.body)
        asset = json_response.first

        expect(asset).to include('id', 'name', 'type', 'created_at', 'updated_at')
        expect(asset['category']).to include('id', 'name')
        expect(asset['category']['name']).to eq('Stocks')
      end
    end

    context 'with category filter' do
      let!(:bond_category) { create(:category, name: 'Bonds') }
      let!(:bond_asset) { create(:asset, name: 'US Treasury', category: bond_category, type: 'BondAsset') }

      before do
        request.headers.merge!(auth_headers)
        get :index, params: { category_id: category.id }, format: :json
      end

      it 'returns only assets from specified category' do
        json_response = JSON.parse(response.body)
        expect(json_response.length).to eq(2)
        json_response.each do |asset|
          expect(asset['category']['id']).to eq(category.id)
        end
      end
    end

    context 'without authentication' do
      it 'returns unauthorized status' do
        get :index, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) { { name: 'New Asset', category_id: category.id, type: 'StockAsset' } }
    let(:invalid_attributes) { { name: nil, category_id: category.id, type: 'StockAsset' } }

    context 'with valid attributes' do
      before do
        request.headers.merge!(auth_headers)
        post :create, params: { asset: valid_attributes }, format: :json
      end

      it 'creates a new asset' do
        expect(response).to have_http_status(:created)
        expect(Asset.count).to eq(3)
      end
    end

    context 'with invalid attributes' do
      before do
        request.headers.merge!(auth_headers)
        post :create, params: { asset: invalid_attributes }, format: :json
      end

      it 'does not create a new asset' do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(Asset.count).to eq(2)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized status' do
        post :create, params: { asset: valid_attributes }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH #set_price' do
    let(:price_params) { { price: 150.00 } }

    context 'with valid params' do
      before do
        request.headers.merge!(auth_headers)
        patch :set_price, params: { id: asset1.id, asset: price_params }, format: :json
      end

      it 'sets the price for the asset' do
        expect(response).to have_http_status(:ok)
        expect(asset1.asset_prices.count).to eq(1)
        expect(asset1.latest_price.price).to eq(150.00)
      end
    end

    context 'with invalid asset id' do
      it 'returns not found' do
        request.headers.merge!(auth_headers)
        patch :set_price, params: { id: -1, asset: price_params }, format: :json
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when price setting fails' do
      before do
        allow_any_instance_of(Asset).to receive(:manual_set_price).and_return(false)
        request.headers.merge!(auth_headers)
        patch :set_price, params: { id: asset1.id, asset: price_params }, format: :json
      end

      it 'returns unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized status' do
        patch :set_price, params: { id: asset1.id, asset: price_params }, format: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
