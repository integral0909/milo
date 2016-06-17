class CreateChecking < ActiveRecord::Migration
  def change
    create_table :checkings do |t|
      t.integer :user_id
      t.integer :plaid_acct_id
      t.timestamps null: false
    end
  end
end
