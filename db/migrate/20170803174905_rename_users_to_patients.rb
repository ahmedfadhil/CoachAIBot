class RenameUsersToPatients < ActiveRecord::Migration[5.1]
  def change
    rename_table :users, :patients
  end
end
