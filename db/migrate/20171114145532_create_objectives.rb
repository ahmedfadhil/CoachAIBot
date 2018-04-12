class CreateObjectives < ActiveRecord::Migration[5.1]
  def change
    create_table :objectives do |t|
      t.references :user
      t.integer :scheduler
      t.integer :activity
      t.integer :steps
      t.integer :distance
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
