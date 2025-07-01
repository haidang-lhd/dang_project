# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication Integration', type: :request do
  let(:user_attributes) do
    {
      email: 'integration@example.com',
      password: 'password123',
      password_confirmation: 'password123',
    }
  end

  describe 'Complete Authentication Flow' do
    it 'allows user to register, confirm, login, and access protected resources' do
      # Step 1: User Registration
      post '/signup', params: { user: user_attributes }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['status']['message']).to eq('Signed up successfully.')

      user = User.find_by(email: user_attributes[:email])
      expect(user).to be_present
      expect(user.confirmed?).to be_falsey

      # Step 2: Login should fail for unconfirmed user
      post '/login', params: {
        user: {
          email: user_attributes[:email],
          password: user_attributes[:password],
        },
      }, as: :json

      expect(response).to have_http_status(:unauthorized)

      # Step 3: Confirm account
      confirmation_token = user.confirmation_token
      get '/confirmation', params: { confirmation_token: confirmation_token }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['status']['message']).to eq('Account confirmed successfully.')

      user.reload
      expect(user.confirmed?).to be_truthy

      # Step 4: Login should now succeed
      post '/login', params: {
        user: {
          email: user_attributes[:email],
          password: user_attributes[:password],
        },
      }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['status']['message']).to eq('Logged in successfully.')

      # JWT token should be in both header and response body
      expect(response.headers['Authorization']).to be_present
      expect(json_response['status']['data']['token']).to be_present

      jwt_token = json_response['status']['data']['token']

      # Step 5: Access protected resource
      get '/api/v1/assets', headers: { 'Authorization' => "Bearer #{jwt_token}" }, as: :json

      expect(response).to have_http_status(:ok)

      # Step 6: Logout
      delete '/logout', headers: { 'Authorization' => "Bearer #{jwt_token}" }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['status']['message']).to eq('Logged out successfully.')
    end
  end

  describe 'Password Reset Flow' do
    let!(:user) { create(:user, :confirmed, email: 'reset@example.com') }

    it 'allows user to reset password via email' do
      # Step 1: Request password reset
      post '/password', params: { user: { email: user.email } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['status']['message']).to eq('Password reset instructions sent successfully.')

      user.reload
      expect(user.reset_password_token).to be_present

      # Step 2: Reset password with token
      # Generate a proper reset token using Devise's method
      raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)
      user.update!(reset_password_token: hashed_token, reset_password_sent_at: Time.current)

      new_password = 'newpassword123'

      put '/password', params: {
        user: {
          reset_password_token: raw_token,
          password: new_password,
          password_confirmation: new_password,
        },
      }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['status']['message']).to eq('Password updated successfully.')

      # Step 3: Login with new password
      post '/login', params: {
        user: {
          email: user.email,
          password: new_password,
        },
      }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_response['status']['message']).to eq('Logged in successfully.')
    end
  end

  describe 'Error Handling' do
    it 'handles validation errors properly' do
      # Invalid email format
      post '/signup', params: {
        user: {
          email: 'invalid-email',
          password: 'short',
          password_confirmation: 'different',
        },
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response['status']['message']).to include("User couldn't be created successfully")
    end

    it 'handles unauthorized access to protected resources' do
      get '/api/v1/assets', as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it 'handles invalid JWT tokens' do
      get '/api/v1/assets', headers: { 'Authorization' => 'Bearer invalid_token' }, as: :json

      expect(response).to have_http_status(:unauthorized)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
