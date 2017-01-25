class AddMaxContributionToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :max_contribution, :integer
    add_column :businesses, :match_percent, :integer
    remove_column :businesses, :contribution
  end
end
