# frozen_string_literal: true

class Api::V1::Users::ConfirmationsController < Devise::ConfirmationsController
  respond_to :json

  # POST /api/v1/users/confirmation
  def create
    if params[:confirmation_token].present?
      # Handle confirmation with token
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      if resource.errors.empty?
        render json: {
          status: {
            code: 200,
            message: 'Account confirmed successfully.',
          },
        }, status: :ok
      else
        render json: {
          status: {
            message: resource.errors.full_messages.to_sentence,
          },
        }, status: :unprocessable_entity
      end
    else
      # Handle sending confirmation instructions
      self.resource = resource_class.send_confirmation_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        render json: {
          status: {
            code: 200,
            message: 'Confirmation instructions sent successfully.',
          },
        }, status: :ok
      else
        render json: {
          status: {
            message: resource.errors.full_messages.to_sentence,
          },
        }, status: :unprocessable_entity
      end
    end
  end

  protected

  def resource_params
    params.require(:user).permit(:email)
  end
end
