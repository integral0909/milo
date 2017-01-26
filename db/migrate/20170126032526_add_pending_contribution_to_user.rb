class AddPendingContributionToUser < ActiveRecord::Migration
  def change
    add_column :users, :pending_contribution, :integer
  end
end
