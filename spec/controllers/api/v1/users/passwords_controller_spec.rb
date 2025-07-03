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

    context 'with valid email' do
      it 'sends password reset instructions' do
        expect do
          post :create, params: valid_params, format: :json
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'returns success response' do
        post :create, params: valid_params, format: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Password reset instructions sent successfully.')
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
  end

  describe 'PUT #update' do
    let(:reset_password_token) { user.send_reset_password_instructions }

    let(:valid_params) do
      {
        user: {
          reset_password_token: reset_password_token,
          password: 'newpassword123',
          password_confirmation: 'newpassword123',
        },
      }
    end

    let(:invalid_params) do
      {
        user: {
          reset_password_token: 'invalid_token',
          password: 'newpassword123',
          password_confirmation: 'newpassword123',
        },
      }
    end

    context 'with valid token and password' do
      it 'updates the password' do
        put :update, params: valid_params, format: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Password updated successfully.')
      end

      it 'allows user to login with new password' do
        put :update, params: valid_params, format: :json

        user.reload
        expect(user.valid_password?('newpassword123')).to be true
      end
    end

    context 'with invalid token' do
      it 'returns unprocessable entity response' do
        put :update, params: invalid_params, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to include('Password reset failed.')
      end
    end

    context 'with mismatched passwords' do
      let(:mismatched_params) do
        {
          user: {
            reset_password_token: reset_password_token,
            password: 'newpassword123',
            password_confirmation: 'differentpassword',
          },
        }
      end

      it 'returns validation error' do
        put :update, params: mismatched_params, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to include('Password reset failed.')
      end
    end
  end
end
