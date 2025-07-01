# frozen_string_literal: true

class Api::BaseController < ActionController::Base
  require 'jwt'

  # Skip CSRF protection for API endpoints
  skip_before_action :verify_authenticity_token

  # Set default response format to JSON
  before_action :set_default_response_format

  # Require authentication for all API endpoints
  before_action :authenticate_request

  # Handle common exceptions
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def set_default_response_format
    request.format = :json
  end

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split.last if header

    begin
      decoded = jwt_decode(header)
      @current_user = User.find(decoded[:user_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'User not found' }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end

  attr_reader :current_user

  def jwt_decode(token)
    JWT.decode(token, Rails.application.secret_key_base)[0].with_indifferent_access
  end

  def record_not_found
    render json: { error: 'Record not found' }, status: :not_found
  end
end
