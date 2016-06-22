class AddDifferenceColumnTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :new_amount, :float, scale: 2
    add_column :transactions, :difference, :decimal, precision: 8, scale: 2
  end
end
