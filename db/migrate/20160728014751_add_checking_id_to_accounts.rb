class AddCheckingIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :checking_id, :integer
  end
end
