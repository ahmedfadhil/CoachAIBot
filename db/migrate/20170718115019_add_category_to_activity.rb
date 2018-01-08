class AddCategoryToActivity < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :category, :string
  end
end
