class CreateFeatures < ActiveRecord::Migration[5.1]
  def change
    create_table :features do |t|
      t.integer :physical
      t.integer :health
      t.integer :mental
      t.integer :coping
      t.string :physical_sport
      t.string :physical_sport_frequency
      t.string :physical_sport_intensity
      t.string :physical_goal
      t.string :health_personality
      t.string :health_wellbeing_meaning
      t.string :health_nutritional_habits
      t.string :health_drinking_water
      t.string :health_vegetables_eaten
      t.string :health_energy_level
      t.string :coping_stress
      t.string :coping_sleep_hours
      t.string :coping_energy_level
      t.string :mental_nervous
      t.string :mental_depressed
      t.string :mental_effort
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
