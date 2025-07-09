# frozen_string_literal: true

class Api::V1::ProfitAnalyticsController < Api::V1::BaseController
  before_action :authenticate_user!

  def calculate_profit
    service = ProfitAnalyticsService.new(current_user)
    @result = service.calculate_profit

    render :calculate_profit, status: :ok
  end
end
