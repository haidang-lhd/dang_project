# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  respond_to :json

  # GET /users/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      render json: {
        status: {
          code: 200,
          message: 'Account confirmed successfully.'
        }
      }, status: :ok
    else
      render json: {
        status: {
          message: "Account confirmation failed. #{resource.errors.full_messages.to_sentence}"
        }
      }, status: :unprocessable_entity
    end
  end

  # POST /users/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      render json: {
        status: {
          code: 200,
          message: 'Confirmation instructions sent successfully.'
        }
      }, status: :ok
    else
      render json: {
        status: {
          message: "Email not found."
        }
      }, status: :not_found
    end
  end

  private

  def resource_params
    params.require(:user).permit(:email)
  end
end
