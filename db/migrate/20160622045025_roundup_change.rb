class RoundupChange < ActiveRecord::Migration
  def change
    add_column :transactions, :roundup, :float, scale: 2
  end
end
