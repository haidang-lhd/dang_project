# frozen_string_literal: true

class Api::V1::AssetPricesController < Api::V1::BaseController
  before_action :authenticate_user!

  def sync
    SyncAllAssetPricesJob.perform_later
    render json: {
      status: {
        code: 202,
        message: 'Price sync job started successfully',
        data: {
          job_status: 'queued',
          message: 'Asset prices will be synchronized in the background',
        },
      },
    }, status: :accepted
  end
end
