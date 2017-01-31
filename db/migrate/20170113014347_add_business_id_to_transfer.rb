class AddBusinessIdToTransfer < ActiveRecord::Migration
  def change
    add_column :transfers, :business_id, :integer
  end
end
