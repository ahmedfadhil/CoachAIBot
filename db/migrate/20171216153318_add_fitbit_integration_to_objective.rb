class AddFitbitIntegrationToObjective < ActiveRecord::Migration[5.1]
  def change
    add_column :objectives, :fitbit_integration, :boolean
  end
end
