class AddTransferTypeToTransfer < ActiveRecord::Migration
  def change
    add_column :transfers, :transfer_type, :string
    remove_column :transfers, :type, :string
  end
end
