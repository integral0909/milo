class AddActiveToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :active, :boolean
    add_column :goals, :completed, :boolean
  end
end
