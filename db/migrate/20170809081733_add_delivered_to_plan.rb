class AddDeliveredToPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :delivered, :integer
  end
end
