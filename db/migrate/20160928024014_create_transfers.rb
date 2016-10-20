class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.string :dwolla_url
      t.string :user_id
      t.string :roundup_count
      t.string :roundup_ammount
      t.string :status
      t.string :type

      t.timestamps null: false
    end
  end
end
