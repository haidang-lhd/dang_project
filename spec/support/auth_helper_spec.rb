# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthHelper, type: :request do
  let(:user) { create(:user) }

  it 'generates valid JWT auth headers' do
    headers = auth_headers_for(user)
    expect(headers['Authorization']).to start_with('Bearer ')

    # Verify the token
    token = headers['Authorization'].split.last
    decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
    expect(decoded.first['user_id']).to eq(user.id)
  end
end
