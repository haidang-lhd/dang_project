class AddTypeToAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :assets, :type, :string
    add_index :assets, :type
  end
end

