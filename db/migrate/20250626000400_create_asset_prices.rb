class CreateAssetPrices < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_prices do |t|
      t.references :asset, null: false, foreign_key: true
      t.decimal :price, null: false, precision: 15, scale: 2
      t.datetime :synced_at, null: false
      t.timestamps
    end
  end
end
