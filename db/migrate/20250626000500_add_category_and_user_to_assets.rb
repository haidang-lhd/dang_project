class AddCategoryAndUserToAssets < ActiveRecord::Migration[7.0]
  def change
    add_reference :assets, :category, null: false, foreign_key: true
    add_reference :assets, :user, null: false, foreign_key: true
    remove_column :assets, :price, :decimal, if_exists: true
  end
end
