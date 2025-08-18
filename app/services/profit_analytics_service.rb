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

  def calculate_profit_detail
    transactions = user.investment_transactions.includes(:asset, asset: :category)

    detailed_data = transactions.group_by { |t| t.asset.category.name }.transform_values do |category_transactions|
      category_transactions.group_by { |t| t.asset.name }.transform_values do |asset_transactions|
        asset_transactions.map do |transaction|
          {
            transaction_id: transaction.id,
            asset_name: transaction.asset.name,
            category_name: transaction.asset.category.name,
            quantity: transaction.quantity,
            nav: transaction.nav,
            invested: (transaction.quantity * transaction.nav).round(2),
            current_value: (transaction.quantity * transaction.asset.current_price).round(2),
            profit: ((transaction.quantity * transaction.asset.current_price) - (transaction.quantity * transaction.nav)).round(2),
            profit_percentage: calculate_profit_percentage(
              (transaction.quantity * transaction.asset.current_price) - (transaction.quantity * transaction.nav),
              transaction.quantity * transaction.nav
            ).round(2),
            investment_date: transaction.created_at.strftime('%Y-%m-%d'),
          }
        end
      end
    end

    { detailed_data: detailed_data }
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

    asset_data = {
      asset: asset,
      invested: asset_invested,
      current_value: asset_current_value,
      profit: asset_profit,
      profit_percentage: asset_profit_percentage,
      quantity: asset_quantity,
    }
    add_asset_to_category(category_name, category_data, asset_data)
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
    asset_transactions.sum do |t|
      amount = t.quantity * t.nav
      t.transaction_type == 'sell' ? -amount : amount
    end
  end

  def calculate_asset_quantity(asset_transactions)
    asset_transactions.sum do |t|
      t.transaction_type == 'sell' ? -t.quantity : t.quantity
    end
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

  def add_asset_to_category(category_name, category_data, asset_data)
    asset = asset_data[:asset]
    category_data[category_name][:assets] << {
      id: asset.id,
      name: asset.name,
      invested: asset_data[:invested].round(2),
      current_value: asset_data[:current_value].round(2),
      profit: asset_data[:profit].round(2),
      profit_percentage: asset_data[:profit_percentage].round(2),
      quantity: asset_data[:quantity].round(4),
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
