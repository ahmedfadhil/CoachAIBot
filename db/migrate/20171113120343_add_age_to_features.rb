class AddAgeToFeatures < ActiveRecord::Migration[5.1]
  def change
    add_column :features, :age, :integer
  end
end
