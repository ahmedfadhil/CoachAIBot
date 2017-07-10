class AddFieldsToPlan < ActiveRecord::Migration[5.1]
  def change
    add_reference :plans, :coach_user, foreign_key: true
  end
end
