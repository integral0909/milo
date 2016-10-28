class AddAccountBalanceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_balance, :string
  end
end
