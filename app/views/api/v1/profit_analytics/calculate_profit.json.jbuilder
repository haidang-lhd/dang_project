json.status do
  json.code 200
  json.message 'Profit calculation completed successfully'
  json.data do
    json.chart_data do
      json.categories @result[:chart_data][:categories] do |category|
        json.label category[:label]
        json.invested category[:invested]
        json.current_value category[:current_value]
        json.profit category[:profit]
        json.profit_percentage category[:profit_percentage]
      end

      json.portfolio_summary do
        json.total_invested @result[:chart_data][:portfolio_summary][:total_invested]
        json.total_current_value @result[:chart_data][:portfolio_summary][:total_current_value]
        json.total_profit @result[:chart_data][:portfolio_summary][:total_profit]
        json.total_profit_percentage @result[:chart_data][:portfolio_summary][:total_profit_percentage]
      end
    end

    json.category_details @result[:category_details] do |category_name, category_data|
      json.set! category_name do
        json.invested category_data[:invested]
        json.current_value category_data[:current_value]
        json.profit category_data[:profit]
        json.profit_percentage category_data[:profit_percentage]
        json.assets category_data[:assets] do |asset|
          json.id asset[:id]
          json.name asset[:name]
          json.invested asset[:invested]
          json.current_value asset[:current_value]
          json.profit asset[:profit]
          json.profit_percentage asset[:profit_percentage]
          json.quantity asset[:quantity]
          json.current_price asset[:current_price]
        end
      end
    end
  end
end

