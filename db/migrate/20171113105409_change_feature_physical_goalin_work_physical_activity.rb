class ChangeFeaturePhysicalGoalinWorkPhysicalActivity < ActiveRecord::Migration[5.1]
  def change
    rename_column :features, :physical_goal, :work_physical_activity
  end
end
