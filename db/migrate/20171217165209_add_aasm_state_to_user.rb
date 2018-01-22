class AddAasmStateToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :aasm_state, :string
  end
end
