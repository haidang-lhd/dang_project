class AddUserToCategoriesAndLabels < ActiveRecord::Migration[7.0]
  def change
    add_reference :categories, :user, null: false, foreign_key: true unless column_exists?(:categories, :user_id)
    add_reference :labels, :user, null: false, foreign_key: true unless column_exists?(:labels, :user_id)
  end
end
