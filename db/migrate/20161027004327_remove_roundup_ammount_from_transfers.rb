class RemoveRoundupAmmountFromTransfers < ActiveRecord::Migration
  def change
    remove_column :transfers, :roundup_ammount, :string
    add_column    :transfers, :roundup_amount, :string
  end
end
