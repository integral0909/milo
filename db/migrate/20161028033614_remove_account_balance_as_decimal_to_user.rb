class RemoveAccountBalanceAsDecimalToUser < ActiveRecord::Migration
  def change
    remove_column :users, :account_balance
    add_column :users, :account_balance, :integer
  end
end
