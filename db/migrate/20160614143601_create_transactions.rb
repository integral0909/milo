class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions, {id: false} do |t|
      t.string   :plaid_trans_id
      t.string   :account_id
      t.float    :amount
      t.string   :trans_name
      t.integer  :plaid_cat_id
      t.string   :plaid_cat_type
      t.date     :date
      t.string   :vendor_address
      t.string   :vendor_city
      t.string   :vendor_state
      t.string   :vendor_zip
      t.float    :vendor_lat
      t.float    :vendor_lon
      t.boolean  :pending
      t.string   :pending_transaction
      t.integer  :name_score

      t.timestamps null: false
    end
  end
end
