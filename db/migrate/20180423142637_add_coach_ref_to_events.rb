class AddCoachRefToEvents < ActiveRecord::Migration[5.1]
  def change
    add_reference :events, :coach_user, foreign_key: true
  end
end
