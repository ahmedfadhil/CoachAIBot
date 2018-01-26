class AddCompletedToQuestionnaire < ActiveRecord::Migration[5.1]
  def change
    def change
      add_column :questionnaires, :completed, :boolean
    end
  end
end
