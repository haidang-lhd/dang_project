# frozen_string_literal: true

module AuthHelper
  def auth_headers_for(user)
    token = jwt_token_for(user)
    { 'Authorization' => "Bearer #{token}" }
  end

  private

  def jwt_token_for(user)
    JWT.encode(
      { user_id: user.id, exp: 24.hours.from_now.to_i },
      Rails.application.credentials.jwt_secret_key || Rails.application.secret_key_base
    )
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
