# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  respond_to :json

  private

  def authenticate_user!
    if request.headers['Authorization'].present?
      authenticate_or_request_with_http_token do |token|
        begin
          jwt_payload = JWT.decode(token, Rails.application.credentials.jwt_secret_key || Rails.application.secret_key_base).first
          @current_user_id = jwt_payload['sub']
        rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
          head :unauthorized
          return false
        end
      end
    else
      head :unauthorized unless devise_controller?
    end
  end

  def current_user
    @current_user ||= User.find(@current_user_id) if @current_user_id
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email])
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[email])
  end
end
