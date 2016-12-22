class AddBankNotVerifiedToUser < ActiveRecord::Migration
  def change
    add_column :users, :bank_not_verified, :boolean
    remove_column :users, :bank_verified, :boolean
  end
end
