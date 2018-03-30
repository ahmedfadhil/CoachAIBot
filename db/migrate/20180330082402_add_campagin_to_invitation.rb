class AddCampaginToInvitation < ActiveRecord::Migration[5.1]
  def change
    add_column :invitations, :campaign, :string
  end
end
