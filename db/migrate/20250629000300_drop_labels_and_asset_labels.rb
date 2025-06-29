class DropLabelsAndAssetLabels < ActiveRecord::Migration[7.0]
  def up
    drop_table :asset_labels if table_exists?(:asset_labels)
    drop_table :labels if table_exists?(:labels)
  end

  def down
    create_table :labels do |t|
      t.string :name, null: false
      t.timestamps
    end

    create_table :asset_labels do |t|
      t.references :asset, null: false, foreign_key: true
      t.references :label, null: false, foreign_key: true
      t.timestamps
    end
  end
end
