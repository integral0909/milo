class OnDemandToUser < ActiveRecord::Migration
  def change
    add_column :users, :on_demand, :boolean
  end
end
