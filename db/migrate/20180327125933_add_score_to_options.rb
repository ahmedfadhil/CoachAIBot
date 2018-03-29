class AddScoreToOptions < ActiveRecord::Migration[5.1]
  def change
    add_column :options, :score, :integer
  end
end
