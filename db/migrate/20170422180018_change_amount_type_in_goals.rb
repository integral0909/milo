class ChangeAmountTypeInGoals < ActiveRecord::Migration
  def change
    change_column :goals, :amount, :decimal
  end
end
