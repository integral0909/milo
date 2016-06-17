class ChangeCheckingString < ActiveRecord::Migration
  def change
    change_column :checkings, :plaid_acct_id, :string
  end
end
