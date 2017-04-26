class AddDefaultToUserBalance < ActiveRecord::Migration
  def change
    change_column :users, :account_balance, :integer, default: 0
    User.where(account_balance: nil).each do |user|
      user.account_balance = 0
      user.save!
    end
  end
end
