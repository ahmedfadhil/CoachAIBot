class AddCompletedToInvitation < ActiveRecord::Migration[5.1]
  def change
    add_column :invitations, :completed, :boolean
  end
end
