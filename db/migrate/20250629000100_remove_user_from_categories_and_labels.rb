class RemoveUserFromCategoriesAndLabels < ActiveRecord::Migration[7.0]
  def change
    remove_reference :categories, :user, foreign_key: true
    remove_reference :labels, :user, foreign_key: true
  end
end
