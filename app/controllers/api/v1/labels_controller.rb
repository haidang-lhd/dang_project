module Api
  module V1
    class LabelsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_label, only: [:show, :update, :destroy]

      def index
        @labels = current_user.labels
        render json: @labels
      end

      def show
        render json: @label
      end

      def create
        @label = current_user.labels.new(label_params)
        if @label.save
          render json: @label, status: :created
        else
          render json: @label.errors, status: :unprocessable_entity
        end
      end

      def update
        if @label.update(label_params)
          render json: @label
        else
          render json: @label.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @label.destroy
        head :no_content
      end

      private
      def set_label
        @label = current_user.labels.find(params[:id])
      end

      def label_params
        params.require(:label).permit(:name)
      end
    end
  end
end
