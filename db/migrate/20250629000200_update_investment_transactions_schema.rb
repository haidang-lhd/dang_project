class UpdateInvestmentTransactionsSchema < ActiveRecord::Migration[7.0]
  def up
    remove_column :investment_transactions, :amount, :decimal
    add_column :investment_transactions, :quantity, :decimal, precision: 15, scale: 4, null: false
    add_column :investment_transactions, :unit, :string, null: false
    add_column :investment_transactions, :nav, :decimal, precision: 15, scale: 4, null: false
    add_column :investment_transactions, :fee, :decimal, precision: 15, scale: 2
    add_column :investment_transactions, :total_amount, :decimal, precision: 15, scale: 2
  end

  def down
    add_column :investment_transactions, :amount, :decimal, null: false
    remove_column :investment_transactions, :quantity, :decimal
    remove_column :investment_transactions, :unit, :string
    remove_column :investment_transactions, :nav, :decimal
    remove_column :investment_transactions, :fee, :decimal
    remove_column :investment_transactions, :total_amount, :decimal
  end
end
