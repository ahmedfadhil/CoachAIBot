# This migration comes from weight_diary (originally 20170805075738)
class CreateWeightDiaryMeasurments < ActiveRecord::Migration[5.1]
  def change
    create_table :weight_diary_measurments do |t|
      t.references :user, foreign_key: true
      t.decimal :weight
      t.decimal :water_percent
      t.decimal :muscle_percent
      t.decimal :body_fat_percent
      t.decimal :waist_circumference
      t.decimal :waist_to_height_ration
      t.decimal :hip_circumference
      t.decimal :waist_hip_ratio

      t.timestamps
    end
  end
end
