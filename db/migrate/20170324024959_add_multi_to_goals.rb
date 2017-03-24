class AddMultiToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :type, :string
    add_column :goals, :percentage, :decimal
    add_column :goals, :balance, :decimal
  end
end
