# frozen_string_literal: true

module AuthenticationHelpers
  def generate_jwt_token(user)
    JWT.encode(
      {
        sub: user.id,
        exp: 24.hours.from_now.to_i,
      },
      Rails.application.credentials.jwt_secret_key || Rails.application.secret_key_base
    )
  end

  def auth_headers(user)
    token = generate_jwt_token(user)
    { 'Authorization' => "Bearer #{token}" }
  end

  def json_response
    JSON.parse(response.body)
  end

  def expect_success_response(message = nil)
    expect(response).to have_http_status(:ok)
    expect(json_response['status']['code']).to eq(200)
    expect(json_response['status']['message']).to eq(message) if message
  end

  def expect_error_response(status, message = nil)
    expect(response).to have_http_status(status)
    expect(json_response['status']['message']).to include(message) if message
  end

  def expect_jwt_token_in_response
    # Check JWT token in both header and response body
    expect(response.headers['Authorization']).to be_present
    expect(response.headers['Authorization']).to match(/^Bearer .+/)

    expect(json_response['status']['data']['token']).to be_present
    expect(json_response['status']['data']['token']).to be_a(String)
    expect(json_response['status']['data']['token']).to match(/^[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+$/)
  end

  def extract_jwt_token_from_response
    json_response['status']['data']['token']
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :controller
  config.include AuthenticationHelpers, type: :request
end
