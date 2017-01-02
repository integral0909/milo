class AddPauseSavingsToUser < ActiveRecord::Migration
  def change
    add_column :users, :pause_savings, :boolean
  end
end
