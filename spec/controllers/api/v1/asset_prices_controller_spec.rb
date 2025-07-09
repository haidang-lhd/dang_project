# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AssetPricesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_headers) do
    token = JWT.encode({ sub: user.id }, Rails.application.secret_key_base)
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'POST #sync' do
    context 'when authenticated' do
      before { request.headers.merge!(valid_headers) }

      it 'enqueues SyncAllAssetPricesJob' do
        expect { post :sync }.to have_enqueued_job(SyncAllAssetPricesJob)
      end

      it 'returns success response' do
        post :sync
        expect(response).to have_http_status(:accepted)

        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(202)
        expect(json_response['status']['message']).to eq('Price sync job started successfully')
        expect(json_response['status']['data']['job_status']).to eq('queued')
      end
    end

    context 'when not authenticated' do
      it 'returns unauthorized' do
        post :sync
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
