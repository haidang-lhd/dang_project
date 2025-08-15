# frozen_string_literal: true

class Api::V1::ProfitAnalyticsController < Api::V1::BaseController
  before_action :authenticate_user!

  def calculate_profit
    service = ProfitAnalyticsService.new(current_user)
    @result = service.calculate_profit

    render :calculate_profit, status: :ok
  end

  def calculate_profit_detail
    service = ProfitAnalyticsService.new(current_user)
    @result = service.calculate_profit_detail

    render json: @result, status: :ok
  end
end
