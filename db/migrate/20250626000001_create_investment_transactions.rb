class CreateInvestmentTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :investment_transactions do |t|
      t.references :asset, null: false, foreign_key: true
      t.decimal :amount, null: false
      t.string :transaction_type, null: false
      t.date :date, null: false
      t.timestamps
    end
  end
end
