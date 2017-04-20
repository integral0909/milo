class AddAuthenticationTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auth_token, :string, default: ""
    User.find_each do |user|
      user.generate_authentication_token!
      user.save
    end
    add_index :users, :auth_token, unique: true
  end
end
