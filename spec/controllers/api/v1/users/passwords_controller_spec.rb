# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Users::PasswordsController, type: :controller do
  let(:user) { create(:user, :confirmed) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
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
        expect(json_response['status']['message']).to eq('Password reset instructions sent successfully.')
      end

      it 'sends password reset email' do
        expect do
          post :create, params: valid_params, format: :json
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'generates reset password token' do
        post :create, params: valid_params, format: :json

        user.reload
        expect(user.reset_password_token).to be_present
        expect(user.reset_password_sent_at).to be_present
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
  end

  describe 'PUT #update' do
    let(:reset_token) { user.send_reset_password_instructions }

    let(:valid_params) do
      {
        user: {
          reset_password_token: reset_token,
          password: 'newpassword123',
          password_confirmation: 'newpassword123',
        },
      }
    end

    let(:invalid_params) do
      {
        user: {
          reset_password_token: reset_token,
          password: 'newpassword123',
          password_confirmation: 'different_password',
        },
      }
    end

    let(:expired_token_params) do
      {
        user: {
          reset_password_token: 'expired_or_invalid_token',
          password: 'newpassword123',
          password_confirmation: 'newpassword123',
        },
      }
    end

    context 'with valid reset token and matching passwords' do
      it 'returns success response' do
        put :update, params: valid_params, format: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Password updated successfully.')
      end

      it 'updates user password' do
        old_encrypted_password = user.encrypted_password
        put :update, params: valid_params, format: :json

        user.reload
        expect(user.encrypted_password).not_to eq(old_encrypted_password)
        expect(user.valid_password?('newpassword123')).to be_truthy
      end

      it 'clears reset password token' do
        put :update, params: valid_params, format: :json

        user.reload
        expect(user.reset_password_token).to be_nil
        expect(user.reset_password_sent_at).to be_nil
      end
    end

    context 'with mismatched passwords' do
      it 'returns validation error' do
        put :update, params: invalid_params, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to include('Password confirmation doesn\'t match Password')
      end

      it 'does not update password' do
        old_encrypted_password = user.encrypted_password
        put :update, params: invalid_params, format: :json

        user.reload
        expect(user.encrypted_password).to eq(old_encrypted_password)
      end
    end

    context 'with invalid or expired token' do
      it 'returns validation error' do
        put :update, params: expired_token_params, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to include('Reset password token is invalid')
      end
    end
  end
end
