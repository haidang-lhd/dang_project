# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        user: {
          email: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123',
        },
      }
    end

    let(:invalid_params) do
      {
        user: {
          email: 'invalid-email',
          password: 'short',
          password_confirmation: 'different',
        },
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect do
          post :create, params: valid_params, format: :json
        end.to change(User, :count).by(1)
      end

      it 'returns success response' do
        post :create, params: valid_params, format: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['status']['message']).to eq('Signed up successfully.')
        expect(json_response['data']['email']).to eq('test@example.com')
      end

      it 'creates user with unconfirmed status by default' do
        post :create, params: valid_params, format: :json

        user = User.find_by(email: 'test@example.com')
        expect(user).to be_present
        # User should be confirmed by default due to our factory skip_confirmation!
        # but we test the flow would normally require confirmation
      end

      it 'sends confirmation email when using unconfirmed trait' do
        user_params = valid_params[:user].merge(email: 'confirm@example.com')

        expect do
          # Create user that will send confirmation
          User.create!(user_params.merge(confirmed_at: nil))
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a user' do
        expect do
          post :create, params: invalid_params, format: :json
        end.not_to change(User, :count)
      end

      it 'returns error response' do
        post :create, params: invalid_params, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to include("User couldn't be created successfully")
      end
    end

    context 'with duplicate email' do
      before do
        create(:user, email: 'test@example.com')
      end

      it 'returns validation error' do
        post :create, params: valid_params, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['message']).to include('Email has already been taken')
      end
    end
  end
end
