# frozen_string_literal: true

module Api
  module V1
    class AssetsController < ApplicationController
      before_action :set_asset, only: %i[set_price]

      def index
        @assets = if params[:category_id]
                    Asset.where(category_id: params[:category_id])
                  else
                    Asset.all
                  end
        render :index
      end

      def create
        @asset = Asset.new(asset_params)
        if @asset.save
          render json: @asset, status: :created
        else
          render json: @asset.errors, status: :unprocessable_entity
        end
      end

      def set_price
        if @asset.manual_set_price(price_params[:price])
          render json: @asset.latest_price, status: :ok
        else
          render json: { error: 'Failed to set asset price' }, status: :unprocessable_entity
        end
      end

      private

      def set_asset
        @asset = Asset.find(params[:id])
      end

      def asset_params
        params.require(:asset).permit(:name, :type, :category_id)
      end

      def price_params
        params.require(:asset).permit(:price)
      end
    end
  end
end
