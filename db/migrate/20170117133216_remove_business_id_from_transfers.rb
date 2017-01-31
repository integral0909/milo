class RemoveBusinessIdFromTransfers < ActiveRecord::Migration
  def up
    remove_column :transfers, :business_id
  end
end
