class Fixobjectivestypes < ActiveRecord::Migration[5.1]
  def change
		change_column :objectives, :fitbit_integration, :integer, using: 'fitbit_integration::integer'
  end
end
