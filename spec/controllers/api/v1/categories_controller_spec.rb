# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :controller do
  render_views # This enables actual view rendering in controller specs

  let!(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{generate_jwt_token(user)}" } }

  describe 'GET #index' do
    let!(:category1) { create(:category, name: 'Stocks') }
    let!(:category2) { create(:category, name: 'Bonds') }

    context 'with authentication' do
      before do
        request.headers.merge!(auth_headers)
        get :index, format: :json
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns all categories ordered by name' do
        json_response = JSON.parse(response.body)
        expect(json_response.length).to eq(2)
        expect(json_response.first['name']).to eq('Bonds')
        expect(json_response.second['name']).to eq('Stocks')
      end

      it 'includes category attributes in response' do
        json_response = JSON.parse(response.body)
        category = json_response.first

        expect(category).to include('id', 'name', 'created_at', 'updated_at')
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
