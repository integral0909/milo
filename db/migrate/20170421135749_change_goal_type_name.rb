class ChangeGoalTypeName < ActiveRecord::Migration
  def change
    rename_column :goals, :type, :gtype
  end
end
