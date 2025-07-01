# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user!

      private

      def authenticate_user!
        # Let Devise handle JWT authentication
        super
      rescue
        render json: {
          status: {
            code: 401,
            message: 'You need to sign in or sign up before continuing.',
          },
        }, status: :unauthorized
      end
    end
  end
end
