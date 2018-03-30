class AddHeightWeightBloodTypeToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :height, :decimal
    add_column :users, :weight, :decimal
    add_column :users, :blood_type, :string
  end
end
