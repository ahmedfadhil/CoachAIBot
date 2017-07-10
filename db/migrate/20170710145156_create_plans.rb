class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.string :name
      t.text :desc
      t.date :from_day
      t.date :to_day

      t.timestamps
    end
  end
end
