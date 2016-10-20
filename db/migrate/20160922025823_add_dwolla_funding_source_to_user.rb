class AddDwollaFundingSourceToUser < ActiveRecord::Migration
  def change
    add_column :users, :dwolla_funding_source, :string
  end
end
