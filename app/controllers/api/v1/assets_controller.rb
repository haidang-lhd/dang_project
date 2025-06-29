module Api
  module V1
    class AssetsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_asset, only: [ :show, :update, :destroy ]

      def index
        @assets = current_user.assets.includes(:category, :labels, :asset_prices)
        render json: @assets, include: [ :category, :labels, :asset_prices ]
      end

      def show
        render json: @asset, include: [ :category, :labels, :asset_prices ]
      end

      def create
        @asset = current_user.assets.new(asset_params)
        if @asset.save
          render json: @asset, status: :created
        else
          render json: @asset.errors, status: :unprocessable_entity
        end
      end

      def update
        if @asset.update(asset_params)
          render json: @asset
        else
          render json: @asset.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @asset.destroy
        head :no_content
      end

      private
      def set_asset
        @asset = current_user.assets.find(params[:id])
      end

      def asset_params
        params.require(:asset).permit(:name, :category_id, label_ids: [])
      end
    end
  end
end
