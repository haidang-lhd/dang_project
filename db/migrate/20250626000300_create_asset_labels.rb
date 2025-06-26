class CreateAssetLabels < ActiveRecord::Migration[7.0]
  def change
    create_table :asset_labels do |t|
      t.references :asset, null: false, foreign_key: true
      t.references :label, null: false, foreign_key: true
      t.timestamps
    end
    add_index :asset_labels, [:asset_id, :label_id], unique: true
  end
end
