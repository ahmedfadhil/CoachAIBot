class CreatePlansUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :plans_users do |t|
      t.references :plan, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
