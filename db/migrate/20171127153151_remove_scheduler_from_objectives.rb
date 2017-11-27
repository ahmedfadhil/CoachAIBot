class RemoveSchedulerFromObjectives < ActiveRecord::Migration[5.1]
  def change
		remove_column :objectives, :scheduler
  end
end
