# frozen_string_literal: true

class Api::V1::Users::PasswordsController < Devise::PasswordsController
  respond_to :json

  # POST /api/v1/users/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      render json: {
        status: {
          code: 200,
          message: 'Password reset instructions sent successfully.',
        },
      }, status: :ok
    else
      render json: {
        status: {
          message: 'Email not found.',
        },
      }, status: :not_found
    end
  end

  # PUT /api/v1/users/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      render json: {
        status: {
          code: 200,
          message: 'Password updated successfully.',
        },
      }, status: :ok
    else
      set_minimum_password_length
      render json: {
        status: {
          message: "Password reset failed. #{resource.errors.full_messages.to_sentence}",
        },
      }, status: :unprocessable_entity
    end
  end

  private

  def resource_params
    params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token)
  end
end
