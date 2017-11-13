class AddFootBicleToFeatures < ActiveRecord::Migration[5.1]
  def change
    add_column :features, :foot_bicycle, :string
  end
end
