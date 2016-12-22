class ChangeContributionScaleToBusiness < ActiveRecord::Migration
  def self.up
   change_column :businesses, :contribution, :decimal, precision: 8, scale: 2
  end
end
