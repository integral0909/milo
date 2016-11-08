class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string :name
      t.text :description
      t.integer :amount
      t.references :user, index: true, foreign_key: true

      t.timestamps
    end
    add_index :goals, [:user_id, :created_at]
  end
end
