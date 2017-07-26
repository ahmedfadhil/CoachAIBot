class CreateFeatures < ActiveRecord::Migration[5.1]
  def change
    create_table :features do |t|
      t.boolean :health
      t.boolean :physical
      t.boolean :mental
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
