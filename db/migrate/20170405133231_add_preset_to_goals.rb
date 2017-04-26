class AddPresetToGoals < ActiveRecord::Migration
  def change
    add_column :goals, :preset, :boolean
  end
end
