class CreateActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities do |t|
      t.string :name
      t.string :desc
      t.string :type
      t.integer :n_times

      t.timestamps
    end
  end
end
