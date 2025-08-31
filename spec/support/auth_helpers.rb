# frozen_string_literal: true

module AuthHelpers
  def auth_headers_for(user)
    token = JWT.encode(
      {
        sub: user.id.to_s,
        jti: SecureRandom.uuid,
        exp: 24.hours.from_now.to_i,
        user_id: user.id, # Add this explicitly for compatibility
      },
      Rails.application.credentials.jwt_secret_key || Rails.application.secret_key_base
    )
    { 'Authorization' => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
