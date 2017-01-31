class AddReferencesToTransfers < ActiveRecord::Migration
  def change
    add_reference :transfers, :business, index: true, foreign_key: true
  end
end
