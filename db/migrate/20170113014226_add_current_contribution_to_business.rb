class AddCurrentContributionToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :current_contribution, :integer
    add_column :businesses, :total_contribution, :integer
  end
end
