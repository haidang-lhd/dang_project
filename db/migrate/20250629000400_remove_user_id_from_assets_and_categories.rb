class RemoveUserIdFromAssetsAndCategories < ActiveRecord::Migration[7.0]
  def change
    if column_exists?(:assets, :user_id)
      remove_reference :assets, :user, foreign_key: true, index: true
    end
    if column_exists?(:categories, :user_id)
      remove_reference :categories, :user, foreign_key: true, index: true
    end
  end
end
