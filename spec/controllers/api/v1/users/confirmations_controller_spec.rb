# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Users::ConfirmationsController, type: :controller do
  let(:user) { create(:user, :unconfirmed) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    # Generate confirmation token for the user
    user.send_confirmation_instructions
  end

  describe 'GET #show' do
    let(:confirmation_token) do
      # Ensure we have a fresh confirmation token
      user.send_confirmation_instructions if user.confirmation_token.blank?
      user.reload.confirmation_token
    end

    context 'with valid confirmation token' do
      it 'confirms the user account' do
        get :show, params: { confirmation_token: confirmation_token }, format: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Account confirmed successfully.')
      end

      it 'marks user as confirmed' do
        get :show, params: { confirmation_token: confirmation_token }, format: :json

        user.reload
        expect(user.confirmed?).to be true
      end
    end

    context 'with invalid confirmation token' do
      it 'returns unprocessable entity response' do
        get :show, params: { confirmation_token: 'invalid_token' }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to include('Account confirmation failed.')
      end

      it 'does not confirm the user' do
        get :show, params: { confirmation_token: 'invalid_token' }, format: :json

        user.reload
        expect(user.confirmed?).to be false
      end
    end

    context 'with already confirmed user' do
      let(:confirmed_user) { create(:user, :confirmed) }

      it 'returns error for already confirmed account' do
        # Generate a token for an already confirmed user
        token = confirmed_user.send(:generate_confirmation_token)

        get :show, params: { confirmation_token: token }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        user: {
          email: user.email,
        },
      }
    end

    let(:invalid_params) do
      {
        user: {
          email: 'nonexistent@example.com',
        },
      }
    end

    context 'with valid email' do
      it 'sends confirmation instructions' do
        expect do
          post :create, params: valid_params, format: :json
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'returns success response' do
        post :create, params: valid_params, format: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Confirmation instructions sent successfully.')
      end
    end

    context 'with invalid email' do
      it 'returns not found response' do
        post :create, params: invalid_params, format: :json

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to eq('Email not found.')
      end

      it 'does not send email' do
        expect do
          post :create, params: invalid_params, format: :json
        end.not_to(change { ActionMailer::Base.deliveries.count })
      end
    end

    context 'with already confirmed user' do
      let(:confirmed_user) { create(:user, :confirmed) }
      let(:confirmed_params) do
        {
          user: {
            email: confirmed_user.email,
          },
        }
      end

      it 'returns error for already confirmed account' do
        post :create, params: confirmed_params, format: :json

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to eq('Email not found.')
      end
    end
  end
end
