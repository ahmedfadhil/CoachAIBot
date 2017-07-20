class ChangeColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :activities, :type, :a_type
  end
end
