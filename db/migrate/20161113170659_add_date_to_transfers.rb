class AddDateToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :date, :string
  end
end
