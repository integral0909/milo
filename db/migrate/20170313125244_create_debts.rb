class CreateDebts < ActiveRecord::Migration
  def change
    create_table :debts do |t|
      t.string  :account_name
      t.string  :account_number
      t.string  :debt_type
      t.decimal :begin_balance
      t.decimal :current_balance
      t.decimal :minimum_payment
      t.decimal :credit_limit
      t.decimal :apr
      t.date    :due_date
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
