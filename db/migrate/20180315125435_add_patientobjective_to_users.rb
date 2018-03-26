class AddPatientobjectiveToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :patient_objective, :string
  end
end
