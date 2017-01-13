class AddEmployerContributionToUser < ActiveRecord::Migration
  def change
    add_column :users, :employer_contribution, :integer
  end
end
