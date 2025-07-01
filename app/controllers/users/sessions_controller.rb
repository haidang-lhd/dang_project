# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix
  respond_to :json

  private

  def respond_with(current_user, _opts = {})
    # Get the token that Devise-JWT generates and sets in the request environment
    token = request.env['warden-jwt_auth.token']

    # If no token from Devise-JWT, generate one manually
    if token.blank?
      token = generate_jwt_token(current_user)
    end

    # Set the Authorization header
    response.headers['Authorization'] = "Bearer #{token}"

    render json: {
      status: {
        code: 200,
        message: 'Logged in successfully.',
        data: {
          user: jbuilder_user_data(current_user),
          token: token,
        },
      },
    }, status: :ok
  end

  def respond_to_on_destroy
    # Check if user is authenticated before destroying session
    if user_signed_in?
      render json: {
        status: {
          code: 200,
          message: 'Logged out successfully.',
        },
      }, status: :ok
    else
      render json: {
        status: {
          code: 401,
          message: "Couldn't find an active session.",
        },
      }, status: :unauthorized
    end
  end

  def generate_jwt_token(user)
    # Generate a token using Devise-JWT's approach
    payload = {
      sub: user.id.to_s,
      jti: SecureRandom.uuid,
      exp: 1.day.from_now.to_i,
    }
    JWT.encode(payload, Rails.application.credentials.jwt_secret_key || Rails.application.secret_key_base)
  end

  def jbuilder_user_data(user)
    Jbuilder.new do |json|
      json.extract! user, :id, :email, :confirmed_at, :created_at, :updated_at
    end.attributes!
  end
end
