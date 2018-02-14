class AddPyClusterToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :py_cluster, :string
  end
end
