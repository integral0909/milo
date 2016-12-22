class AddLongTailToUser < ActiveRecord::Migration
  def change
    add_column :users, :long_tail, :boolean
  end
end
