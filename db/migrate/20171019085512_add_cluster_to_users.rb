class AddClusterToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :cluster, :string
  end
end