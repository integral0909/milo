class CreatePublicTokens < ActiveRecord::Migration
  def change
    create_table :public_tokens do |t|
      t.string :token
      t.string :user_id
    end
  end
end
