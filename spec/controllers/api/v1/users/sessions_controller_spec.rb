# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Users::SessionsController, type: :controller do
  let(:user) { create(:user, :confirmed) }
  let(:unconfirmed_user) { create(:user, :unconfirmed) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        user: {
          email: user.email,
          password: 'password123',
        },
      }
    end

    let(:invalid_params) do
      {
        user: {
          email: user.email,
          password: 'wrong_password',
        },
      }
    end

    context 'with valid credentials and confirmed user' do
      before do
        # Mock successful authentication
        allow(controller).to receive(:resource).and_return(user)
        allow(controller).to receive(:resource_name).and_return(:user)
        allow(controller).to receive(:devise_mapping).and_return(Devise.mappings[:user])
        allow(user).to receive(:persisted?).and_return(true)
        allow(user).to receive(:active_for_authentication?).and_return(true)

        # Mock JWT token generation
        jwt_token = generate_jwt_token(user)
        response.headers['Authorization'] = "Bearer #{jwt_token}"
      end

      it 'returns success response' do
        post :create, params: valid_params, format: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Logged in successfully.')
        expect(json_response['status']['data']['user']['email']).to eq(user.email)
      end

      it 'returns JWT token in Authorization header' do
        post :create, params: valid_params, format: :json

        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to match(/^Bearer .+/)
      end

      it 'returns JWT token in response body' do
        post :create, params: valid_params, format: :json

        json_response = JSON.parse(response.body)
        expect(json_response['status']['data']['token']).to be_present
        expect(json_response['status']['data']['token']).to be_a(String)
        expect(json_response['status']['data']['token']).to match(/^[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+$/) # JWT format
      end

      it 'includes user data in response' do
        post :create, params: valid_params, format: :json

        json_response = JSON.parse(response.body)
        user_data = json_response['status']['data']['user']
        expect(user_data['id']).to eq(user.id)
        expect(user_data['email']).to eq(user.email)
        expect(user_data['confirmed_at']).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized response' do
        post :create, params: invalid_params, format: :json

        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not return JWT token' do
        post :create, params: invalid_params, format: :json

        expect(response.headers['Authorization']).to be_nil
      end
    end

    context 'with unconfirmed user' do
      let(:unconfirmed_params) do
        {
          user: {
            email: unconfirmed_user.email,
            password: 'password123',
          },
        }
      end

      it 'returns unauthorized response' do
        post :create, params: unconfirmed_params, format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:jwt_token) { generate_jwt_token(user) }

    context 'with valid JWT token' do
      before do
        request.headers['Authorization'] = "Bearer #{jwt_token}"
        allow(controller).to receive(:current_user).and_return(user)
      end

      it 'returns success response' do
        delete :destroy, format: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Logged out successfully.')
      end
    end

    context 'without JWT token' do
      it 'returns unauthorized response' do
        delete :destroy, format: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to eq("Couldn't find an active session.")
      end
    end

    context 'with invalid JWT token' do
      before do
        request.headers['Authorization'] = 'Bearer invalid_token'
      end

      it 'returns unauthorized response' do
        expect do
          delete :destroy, format: :json
        end.not_to raise_error

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  private

  def generate_jwt_token(user)
    JWT.encode(
      {
        sub: user.id,
        exp: 24.hours.from_now.to_i,
      },
      Rails.application.credentials.jwt_secret_key || Rails.application.secret_key_base
    )
  end
end
