class AddFieldToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :email, :string
    add_column :users, :cellphone, :string
  end
end
