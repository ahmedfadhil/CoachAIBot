class AddCommunicatedToPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :communicated, :boolean
  end
end
