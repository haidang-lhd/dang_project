class AddUserToInvestmentTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :investment_transactions, :user, null: false, foreign_key: true
  end
end
