class AddTechFeeChargedToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :tech_fee_charged, :boolean
  end
end
