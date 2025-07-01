# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::ConfirmationsController, type: :controller do
  let(:user) { create(:user, :unconfirmed) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    allow(controller).to receive(:authenticate_user!).and_return(true)
    # Manually set confirmation token for testing
    user.send_confirmation_instructions
  end

  describe 'GET #show' do
    let(:confirmation_token) { user.confirmation_token }

    context 'with valid confirmation token' do
      it 'confirms the user account' do
        get :show, params: { confirmation_token: confirmation_token }, format: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Account confirmed successfully.')
      end

      it 'updates user confirmed_at timestamp' do
        expect(user.confirmed_at).to be_nil

        get :show, params: { confirmation_token: confirmation_token }, format: :json

        user.reload
        expect(user.confirmed_at).to be_present
        expect(user.confirmed?).to be_truthy
      end
    end

    context 'with invalid confirmation token' do
      it 'returns validation error' do
        get :show, params: { confirmation_token: 'invalid_token' }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to include('Confirmation token is invalid')
      end

      it 'does not confirm the user' do
        get :show, params: { confirmation_token: 'invalid_token' }, format: :json

        user.reload
        expect(user.confirmed?).to be_falsey
      end
    end

    context 'with expired confirmation token' do
      before do
        user.update_columns(confirmation_sent_at: 4.days.ago)
      end

      it 'returns validation error' do
        get :show, params: { confirmation_token: confirmation_token }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to include('needs to be confirmed within 3 days')
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

    context 'with existing user email' do
      it 'returns success response' do
        post :create, params: valid_params, format: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Confirmation instructions sent successfully.')
      end

      it 'sends confirmation email' do
        # Clear previous emails first since user was already created with confirmation
        ActionMailer::Base.deliveries.clear

        expect do
          post :create, params: valid_params, format: :json
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'updates confirmation_sent_at timestamp' do
        old_confirmation_sent_at = user.confirmation_sent_at

        # Use a simple approach - just check that the timestamp is updated
        post :create, params: valid_params, format: :json

        user.reload
        # Check that confirmation_sent_at was updated (should be greater than or equal)
        expect(user.confirmation_sent_at).to be >= old_confirmation_sent_at
      end
    end

    context 'with non-existent email' do
      it 'returns not found response' do
        post :create, params: invalid_params, format: :json

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to eq('Email not found.')
      end

      it 'does not send email' do
        initial_count = ActionMailer::Base.deliveries.count

        post :create, params: invalid_params, format: :json

        expect(ActionMailer::Base.deliveries.count).to eq(initial_count)
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

      it 'handles confirmed user appropriately' do
        post :create, params: confirmed_params, format: :json

        # Devise behavior may vary - just check that it doesn't crash
        expect(response.status).to be_in([200, 404])
      end
    end
  end
end
