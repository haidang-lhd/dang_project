class CreateAssets < ActiveRecord::Migration[7.0]
  def change
    create_table :assets do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
