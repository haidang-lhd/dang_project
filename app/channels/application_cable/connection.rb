# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Extract token from request parameters or headers
      token = request.params[:token] || extract_token_from_headers

      if token && (decoded_token = decode_token(token))
        User.find_by(id: decoded_token['sub'])
      else
        reject_unauthorized_connection
      end
    end

    def extract_token_from_headers
      auth_header = request.headers['Authorization']
      auth_header&.split&.last
    end

    def decode_token(token)
      JWT.decode(token, Rails.application.credentials.jwt_secret_key || Rails.application.secret_key_base)[0]
    rescue JWT::DecodeError
      nil
    end
  end
end
