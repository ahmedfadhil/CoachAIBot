class CreatePlannings < ActiveRecord::Migration[5.1]
  def change
    create_table :plannings do |t|
      t.boolean :finished
      t.references :plan, foreign_key: true
      t.references :activity, foreign_key: true

      t.timestamps
    end
  end
end
