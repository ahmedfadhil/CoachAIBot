class AddPyClusterToFeatures < ActiveRecord::Migration[5.1]
  def change
    add_column :features, :py_cluster, :string
  end
end
