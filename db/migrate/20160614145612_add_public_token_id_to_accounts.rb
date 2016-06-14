class AddPublicTokenIdToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :public_token_id, :integer
  end
end
