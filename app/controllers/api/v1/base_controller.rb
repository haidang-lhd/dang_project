# frozen_string_literal: true

class Api::V1::BaseController < ApplicationController
  respond_to :json

  private

  def current_user
    @current_user ||= super || User.find_by(id: payload['sub'])
  end

  def payload
    auth_header = request.headers['Authorization']
    token = auth_header.split.last if auth_header
    @payload ||= decode_token(token) if token
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    nil
  end

  def decode_token(token)
    JWT.decode(token, Rails.application.credentials.jwt_secret_key || Rails.application.secret_key_base)[0]
  end
end
