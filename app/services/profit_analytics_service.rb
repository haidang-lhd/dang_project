# frozen_string_literal: true

# ProfitAnalyticsService
# ----------------------
# Calculates portfolio and per-transaction analytics using a
# Weighted Average Cost (WAC) approach with robust floating-point handling.
#
# Outputs:
# 1) Aggregated category/asset metrics for a "current state" view
# 2) Per-transaction rows with a **unified schema** for both BUY and SELL
#
# Key guarantees:
# - All WAC math is chronological (sorted by [date, created_at])
# - Floating-point drift is neutralized via EPS guards
# - Sells cannot exceed current holdings (explicit guard)
# - Remaining quantity and remaining cost normalize to zero when near EPS
# - Realized Profit for an asset is the sum of per-sale (proceeds - cost_basis_at_sale),
#   where cost_basis_at_sale uses the WAC *as of that sale* (later transactions are ignored)
#
# Unified transaction row schema (both BUY and SELL include all keys):
# {
#   transaction_id:, transaction_type:, asset_name:, category_name:,
#   quantity:, nav:,
#   invested:,           # BUY: cost of the transaction (qty*nav + fee) ; SELL: cost_basis (WAC*qty)
#   current_value:,      # BUY: qty*current_price ; SELL: sale_proceeds (qty*nav - fee)
#   profit:,             # BUY: current_value - invested (unrealized reference) ; SELL: realized_profit
#   profit_percentage:,  # BUY: profit / invested ; SELL: realized_profit / cost_basis
#   sale_proceeds:,      # BUY: 0.0 ; SELL: qty*nav - fee
#   cost_basis:,         # BUY: 0.0 ; SELL: WAC*qty (capped at remaining_cost)
#   realized_profit:,    # BUY: 0.0 ; SELL: sale_proceeds - cost_basis
#   investment_date:
# }

class ProfitAnalyticsService
  EPS = 1e-6

  attr_reader :user

  def initialize(user)
    @user = user
  end

  # ==== PORTFOLIO / AGGREGATES ===============================================

  # Returns:
  # {
  #   category_details: {
  #     "Category A" => {
  #       invested:, current_value:, profit:, realized_profit:,
  #       profit_percentage:, assets: [
  #         { id:, name:, invested:, current_value:, profit:, realized_profit:, profit_percentage:, quantity:, current_price: },
  #         ...
  #       ]
  #     },
  #     ...
  #   },
  #   chart_data: {
  #     categories: [
  #       {
  #         label:, invested:, current_value:, profit:,
  #         profit_percentage:, realized_profit:, current_value_percentage:
  #       },
  #       ...
  #     ],
  #     portfolio_summary: {
  #       total_invested:, total_current_value:, total_profit:,
  #       total_profit_percentage:, total_realized_profit:
  #     }
  #   }
  # }
  def calculate_profit
    transactions = user.investment_transactions.includes(:asset, asset: :category)

    category_data = {}
    total_invested = 0.0
    total_current_value = 0.0

    # Compute per-asset WAC metrics then roll up to category
    transactions.group_by(&:asset).each do |asset, asset_transactions|
      ordered = asset_transactions.sort_by { |t| [t.created_at, t.id] } # ensure correct WAC

      metrics = calculate_asset_metrics(ordered, asset) # WAC core

      category_name = asset.category.name
      initialize_category_data(category_name, category_data)

      asset_profit_percentage = calculate_profit_percentage(metrics[:profit], metrics[:invested])

      update_category_totals(
        category_name,
        category_data,
        metrics[:invested],
        metrics[:current_value],
        metrics[:profit],
        metrics[:realized_profit]
      )

      # Asset snapshot: remaining quantity, unrealized on remaining, and cumulative realized
      category_data[category_name][:assets] << {
        id: asset.id,
        name: asset.name,
        invested: metrics[:invested].round(2),
        current_value: metrics[:current_value].round(2),
        profit: metrics[:profit].round(2),                    # unrealized on remaining units
        realized_profit: metrics[:realized_profit].round(2),  # cumulative realized from sells
        profit_percentage: asset_profit_percentage.round(2),
        quantity: metrics[:quantity].round(4),                # remaining quantity after sells
        current_price: asset.current_price.round(2),
      }

      total_invested      += metrics[:invested]
      total_current_value += metrics[:current_value]
    end

    finalize_category_data(category_data)

    {
      category_details: category_data,
      chart_data: build_chart_data(category_data, total_invested, total_current_value),
    }
  end

  # ==== PER-TRANSACTION DETAIL ===============================================

  # Returns:
  # {
  #   detailed_data: {
  #     "Category" => {
  #       "Asset A" => [ { unified row }, { unified row }, ... ],
  #       ...
  #     },
  #     ...
  #   }
  # }
  def calculate_profit_detail
    transactions = user.investment_transactions.includes(:asset, asset: :category)

    detailed_data =
      transactions.group_by { |t| t.asset.category.name }.transform_values do |category_transactions|
        category_transactions.group_by { |t| t.asset.name }.transform_values do |asset_transactions|
          asset = asset_transactions.first.asset
          ordered = asset_transactions.sort_by { |t| [t.created_at, t.id] } # Sort by creation time and then id
          build_transaction_rows(ordered, asset)
        end
      end

    { detailed_data: detailed_data }
  end

  private

  # ---------------- WAC core used by aggregates ----------------
  #
  # Iterates chronologically through asset transactions maintaining:
  # - held_qty: current holdings
  # - remaining_cost: cost attached to the remaining holdings
  # - realized_profit: cumulative realized P/L across sells
  #
  # Returns a snapshot per asset:
  # {
  #   invested: remaining_cost,
  #   current_value: held_qty * current_price,
  #   profit: current_value - remaining_cost,     # unrealized on remaining
  #   realized_profit: realized_profit,           # cumulative from sells
  #   quantity: held_qty,
  # }
  def calculate_asset_metrics(asset_transactions, asset)
    held_qty = 0.0
    remaining_cost = 0.0
    realized_profit = 0.0

    asset_transactions.each do |t|
      qty   = t.quantity.to_f
      price = t.nav.to_f
      fee   = t.fee.to_f

      if t.transaction_type == 'buy'
        # Add purchase cost (including fee) and increase holdings
        remaining_cost += qty * price + fee
        held_qty += qty
      else
        # Prevent oversell (allow tiny drift)
        if qty > held_qty + EPS
          raise StandardError, "Sell exceeds holdings for asset #{t.asset_id}"
        end

        # Snap to full liquidation when within EPS
        qty = held_qty if (held_qty - qty).abs < EPS

        # WAC at the moment of sale
        avg_cost = held_qty.positive? ? (remaining_cost / held_qty) : 0.0

        # Cost basis for sold quantity (capped by remaining_cost)
        cost_reduction = [avg_cost * qty, remaining_cost].min

        # Proceeds net of fee
        proceeds = qty * price - fee

        # Realized P/L accumulates only from transactions up to this sale
        realized_profit += proceeds - cost_reduction

        # Update remaining position
        held_qty       -= qty
        remaining_cost -= cost_reduction

        # Normalize tiny float leftovers
        if held_qty.abs < EPS
          held_qty = 0.0
          remaining_cost = 0.0
        end
      end
    end

    current_value = held_qty * asset.current_price.to_f
    unrealized_profit = current_value - remaining_cost

    {
      invested: remaining_cost,
      current_value: current_value,
      profit: unrealized_profit,
      realized_profit: realized_profit,
      quantity: held_qty,
    }
  end

  # ---------------- Per-transaction rows with running WAC ----------------
  #
  # Unified schema for BUY and SELL rows:
  # - BUY:
  #   invested = qty*nav + fee
  #   current_value = qty*current_price
  #   profit = current_value - invested (unrealized reference)
  #   profit_percentage = profit / invested
  #   sale_proceeds = 0.0, cost_basis = 0.0, realized_profit = 0.0
  #
  # - SELL:
  #   cost_basis = WAC*qty (capped by remaining_cost)
  #   sale_proceeds = qty*nav - fee
  #   realized_profit = sale_proceeds - cost_basis
  #   invested = cost_basis (treat as "purchase cost" for this sell row)
  #   current_value = sale_proceeds
  #   profit = realized_profit
  #   profit_percentage = realized_profit / cost_basis
  def build_transaction_rows(asset_transactions, asset)
    rows = []
    held_qty = 0.0
    remaining_cost = 0.0

    asset_transactions.each do |t|
      qty   = t.quantity.to_f
      price = t.nav.to_f
      fee   = t.fee.to_f

      if t.transaction_type == 'buy'
        invested      = qty * price + fee
        current_value = qty * asset.current_price.to_f
        unrealized    = current_value - invested
        profit_pct    = calculate_profit_percentage(unrealized, invested)

        rows << {
          transaction_id: t.id,
          transaction_type: 'buy',
          asset_name: asset.name,
          category_name: asset.category.name,
          quantity: qty,
          nav: price,
          invested: invested.round(2),
          current_value: current_value.round(2),
          profit: unrealized.round(2),                 # unrealized reference on this lot
          profit_percentage: profit_pct.round(2),
          sale_proceeds: 0.0,
          cost_basis: 0.0,
          realized_profit: 0.0,                        # always present for buys
          investment_date: t.created_at.strftime('%Y-%m-%d'),
        }

        # Update running WAC state
        remaining_cost += invested
        held_qty += qty
      else
        # SELL path with protection and drift snapping
        if qty > held_qty + EPS
          raise StandardError, "Sell exceeds holdings for asset #{t.asset_id}"
        end

        qty = held_qty if (held_qty - qty).abs < EPS

        avg_cost   = held_qty.positive? ? (remaining_cost / held_qty) : 0.0
        cost_basis = [avg_cost * qty, remaining_cost].min
        proceeds   = qty * price - fee
        realized   = proceeds - cost_basis
        profit_pct = calculate_profit_percentage(realized, cost_basis)

        rows << {
          transaction_id: t.id,
          transaction_type: 'sell',
          asset_name: asset.name,
          category_name: asset.category.name,
          quantity: qty,
          nav: price,
          invested: cost_basis.round(2),               # treat as "purchase cost" for this sell row
          current_value: proceeds.round(2),            # realized value received
          profit: realized.round(2),                   # realized on cost basis
          profit_percentage: profit_pct.round(2),      # realized / cost_basis
          sale_proceeds: proceeds.round(2),
          cost_basis: cost_basis.round(2),
          realized_profit: realized.round(2),
          investment_date: t.created_at.strftime('%Y-%m-%d'),
        }

        # Update running WAC state post sale
        held_qty       -= qty
        remaining_cost -= cost_basis

        if held_qty.abs < EPS
          held_qty = 0.0
          remaining_cost = 0.0
        end
      end
    end

    rows
  end

  # ---------------- Category helpers ----------------

  # Legacy placeholder (safe to remove if not referenced)
  def process_asset_transactions(_asset, _asset_transactions, _category_data)
    # no-op
  end

  # Ensure category bucket exists
  def initialize_category_data(category_name, category_data)
    category_data[category_name] ||= {
      invested: 0.0,
      current_value: 0.0,
      profit: 0.0,
      realized_profit: 0.0,
      profit_percentage: 0.0,
      assets: [],
    }
  end

  # Defensive percentage helper
  def calculate_profit_percentage(profit, invested)
    invested.to_f.positive? ? (profit.to_f / invested * 100.0) : 0.0
  end

  # Accumulate category totals
  def update_category_totals(category_name, category_data, invested, current_value, profit, realized_profit)
    data = category_data[category_name]
    data[:invested]        += invested
    data[:current_value]   += current_value
    data[:profit]          += profit
    data[:realized_profit] += realized_profit
  end

  # Final rounding and derived percentages per category
  def finalize_category_data(category_data)
    category_data.each_value do |data|
      data[:profit_percentage] = calculate_profit_percentage(data[:profit], data[:invested]).round(2)
      data[:invested]        = data[:invested].round(2)
      data[:current_value]   = data[:current_value].round(2)
      data[:profit]          = data[:profit].round(2)
      data[:realized_profit] = data[:realized_profit].round(2)
    end
  end

  # Build chart payload including per-category weight by current value
  def build_chart_data(category_data, total_invested, total_current_value)
    {
      categories: category_data.map do |name, data|
        current_value_pct =
          total_current_value.positive? ? (data[:current_value] / total_current_value * 100.0).round(2) : 0.0

        {
          label: name,
          invested: data[:invested],
          current_value: data[:current_value],
          profit: data[:profit],
          profit_percentage: data[:profit_percentage],
          realized_profit: data[:realized_profit],
          current_value_percentage: current_value_pct, # weight in portfolio by current value
        }
      end,
      portfolio_summary: {
        total_invested: total_invested.round(2),
        total_current_value: total_current_value.round(2),
        total_profit: (total_current_value - total_invested).round(2),
        total_profit_percentage: calculate_profit_percentage(
          total_current_value - total_invested, total_invested
        ).round(2),
        total_realized_profit: category_data.values.sum { |d| d[:realized_profit] }.round(2),
      },
    }
  end
end
