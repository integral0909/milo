class AddOwnerToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :owner, :integer
  end
end
