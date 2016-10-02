class AddAccountNumberToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :bank_account_number, :string
    add_column :accounts, :bank_routing_number, :string
  end
end
