class ChangeAccountBalanceOnUser < ActiveRecord::Migration
  def change
    remove_column :users, :account_balance
  end
end
