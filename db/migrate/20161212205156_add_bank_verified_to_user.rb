class AddBankVerifiedToUser < ActiveRecord::Migration
  def change
    add_column :users, :bank_verified, :boolean
  end
end
