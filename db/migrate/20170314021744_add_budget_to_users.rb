class AddBudgetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :budget, :decimal, precision: 8, scale: 2
  end
end
