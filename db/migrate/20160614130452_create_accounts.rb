class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts, {id: false} do |t|
      t.string  :plaid_acct_id
      t.string  :account_name
      t.string  :account_number
      t.float   :available_balance
      t.float   :current_balance
      t.string  :institution_type
      t.string  :name
      t.string  :numbers
      t.string  :acct_subtype
      t.string  :acct_type
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
