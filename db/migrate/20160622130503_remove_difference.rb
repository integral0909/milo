class RemoveDifference < ActiveRecord::Migration
  def change
    remove_column :transactions, :difference
  end
end
