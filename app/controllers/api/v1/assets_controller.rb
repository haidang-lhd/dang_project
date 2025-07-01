# frozen_string_literal: true

class Api::V1::AssetsController < Api::V1::BaseController
  def index
    @assets = Asset.includes(:category).order(:name)
    @assets = @assets.where(category_id: params[:category_id]) if params[:category_id].present?
  end
end
