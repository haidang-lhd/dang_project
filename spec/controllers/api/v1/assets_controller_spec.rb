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
end
