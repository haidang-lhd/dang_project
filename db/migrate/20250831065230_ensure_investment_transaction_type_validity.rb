class EnsureInvestmentTransactionTypeValidity < ActiveRecord::Migration[8.0]
  def up
    # Add a check constraint to ensure transaction_type is either 'buy' or 'sell'
    execute <<-SQL
      ALTER TABLE investment_transactions
      ADD CONSTRAINT check_transaction_type_validity
      CHECK (transaction_type IN ('buy', 'sell'))
    SQL

    # Verify existing data - just in case there are invalid values
    execute <<-SQL
      UPDATE investment_transactions
      SET transaction_type = 'buy'
      WHERE transaction_type NOT IN ('buy', 'sell')
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE investment_transactions
      DROP CONSTRAINT IF EXISTS check_transaction_type_validity
    SQL
  end
end
