class CreateBusiness < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string      :name
      t.string      :address
      t.string      :city
      t.string      :state
      t.string      :zip
      t.decimal     :contribution, precision: 2

      t.timestamps
    end
  end
end
