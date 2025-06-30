# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionsFix
  respond_to :json

  private

  def respond_with(current_user, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: jbuilder_user_data(current_user)
      }
    else
      render json: {
        status: { message: "User couldn't be created successfully. #{current_user.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end

  def jbuilder_user_data(user)
    Jbuilder.new do |json|
      json.extract! user, :id, :email, :confirmed_at, :created_at, :updated_at
    end.attributes!
  end
end
