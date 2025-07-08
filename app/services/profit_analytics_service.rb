# frozen_string_literal: true

class ProfitAnalyticsService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def calculate_profit
    transactions = user.investment_transactions.includes(:asset, asset: :category)

    category_data = {}
    total_invested = 0
    total_current_value = 0

    transactions.group_by(&:asset).each do |asset, asset_transactions|
      process_asset_transactions(asset, asset_transactions, category_data)

      asset_invested = calculate_asset_invested(asset_transactions)
      asset_current_value = calculate_asset_current_value(asset_transactions, asset)

      total_invested += asset_invested
      total_current_value += asset_current_value
    end

    finalize_category_data(category_data)

    {
      category_details: category_data,
      chart_data: build_chart_data(category_data, total_invested, total_current_value),
    }
  end

  private

  def process_asset_transactions(asset, asset_transactions, category_data)
    category_name = asset.category.name
    initialize_category_data(category_name, category_data)

    asset_invested = calculate_asset_invested(asset_transactions)
    asset_quantity = calculate_asset_quantity(asset_transactions)
    asset_current_value = calculate_asset_current_value(asset_transactions, asset)
    asset_profit = asset_current_value - asset_invested
    asset_profit_percentage = calculate_profit_percentage(asset_profit, asset_invested)

    update_category_totals(category_name, category_data, asset_invested, asset_current_value, asset_profit)
    add_asset_to_category(category_name, category_data, asset, asset_invested, asset_current_value,
                          asset_profit, asset_profit_percentage, asset_quantity)
  end

  def initialize_category_data(category_name, category_data)
    category_data[category_name] ||= {
      invested: 0,
      current_value: 0,
      profit: 0,
      profit_percentage: 0,
      assets: [],
    }
  end

  def calculate_asset_invested(asset_transactions)
    asset_transactions.sum { |t| t.quantity * t.nav }
  end

  def calculate_asset_quantity(asset_transactions)
    asset_transactions.sum(&:quantity)
  end

  def calculate_asset_current_value(asset_transactions, asset)
    asset_quantity = calculate_asset_quantity(asset_transactions)
    asset_quantity * asset.current_price
  end

  def calculate_profit_percentage(profit, invested)
    invested.positive? ? (profit / invested * 100) : 0
  end

  def update_category_totals(category_name, category_data, invested, current_value, profit)
    category_data[category_name][:invested] += invested
    category_data[category_name][:current_value] += current_value
    category_data[category_name][:profit] += profit
  end

  def add_asset_to_category(category_name, category_data, asset, invested, current_value, profit, profit_percentage, quantity)
    category_data[category_name][:assets] << {
      id: asset.id,
      name: asset.name,
      invested: invested.round(2),
      current_value: current_value.round(2),
      profit: profit.round(2),
      profit_percentage: profit_percentage.round(2),
      quantity: quantity.round(4),
      current_price: asset.current_price.round(2),
    }
  end

  def finalize_category_data(category_data)
    category_data.each_value do |data|
      data[:profit_percentage] = calculate_profit_percentage(data[:profit], data[:invested]).round(2)
      data[:invested] = data[:invested].round(2)
      data[:current_value] = data[:current_value].round(2)
      data[:profit] = data[:profit].round(2)
    end
  end

  def build_chart_data(category_data, total_invested, total_current_value)
    {
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
        total_profit_percentage: calculate_profit_percentage(
          total_current_value - total_invested,
          total_invested
        ).round(2),
      },
    }
  end
end
