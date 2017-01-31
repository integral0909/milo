class AddFrequencyToBusiness < ActiveRecord::Migration
  def change
    add_column :businesses, :frequency, :string
  end
end
