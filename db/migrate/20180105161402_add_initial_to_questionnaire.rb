class AddInitialToQuestionnaire < ActiveRecord::Migration[5.1]
  def change
    add_column :questionnaires, :initial, :boolean
  end
end
