# frozen_string_literal: true

class Api::V1::ProfitAnalyticsController < Api::V1::BaseController
  before_action :authenticate_user!

  def calculate_profit
    transactions = current_user.investment_transactions.includes(:asset, asset: :category)

    # Group transactions by category
    category_data = {}
    total_invested = 0
    total_current_value = 0

    transactions.group_by(&:asset).each do |asset, asset_transactions|
      category_name = asset.category.name
      category_data[category_name] ||= {
        invested: 0,
        current_value: 0,
        profit: 0,
        profit_percentage: 0,
        assets: [],
      }

      # Calculate totals for this asset
      asset_invested = asset_transactions.sum { |t| t.quantity * t.nav }
      asset_quantity = asset_transactions.sum(&:quantity)
      asset_current_value = asset_quantity * asset.current_price
      asset_profit = asset_current_value - asset_invested
      asset_profit_percentage = asset_invested.positive? ? (asset_profit / asset_invested * 100) : 0

      # Add to category totals
      category_data[category_name][:invested] += asset_invested
      category_data[category_name][:current_value] += asset_current_value
      category_data[category_name][:profit] += asset_profit

      # Add asset details
      category_data[category_name][:assets] << {
        id: asset.id,
        name: asset.name,
        invested: asset_invested.round(2),
        current_value: asset_current_value.round(2),
        profit: asset_profit.round(2),
        profit_percentage: asset_profit_percentage.round(2),
        quantity: asset_quantity.round(4),
        current_price: asset.current_price.round(2),
      }

      total_invested += asset_invested
      total_current_value += asset_current_value
    end

    # Calculate category profit percentages
    category_data.each_value do |data|
      data[:profit_percentage] = data[:invested].positive? ? (data[:profit] / data[:invested] * 100).round(2) : 0
      data[:invested] = data[:invested].round(2)
      data[:current_value] = data[:current_value].round(2)
      data[:profit] = data[:profit].round(2)
    end

    # Prepare chart data
    chart_data = {
      categories: category_data.map do |name, data|
        {
          label: name,
          invested: data[:invested],
          current_value: data[:current_value],
          profit: data[:profit],
          profit_percentage: data[:profit_percentage],
        }
      end,
      portfolio_summary: {
        total_invested: total_invested.round(2),
        total_current_value: total_current_value.round(2),
        total_profit: (total_current_value - total_invested).round(2),
        total_profit_percentage: total_invested.positive? ? ((total_current_value - total_invested) / total_invested * 100).round(2) : 0,
      },
    }

    render json: {
      status: {
        code: 200,
        message: 'Profit calculation completed successfully',
        data: {
          chart_data: chart_data,
          category_details: category_data,
        },
      },
    }
  end
end
