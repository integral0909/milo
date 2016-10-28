class AddAccountBalanceAsDecimalToUser < ActiveRecord::Migration
  def change
    add_column :users, :account_balance, :decimal, precision: 7, scale: 2, default: '0.00'
  end
end
