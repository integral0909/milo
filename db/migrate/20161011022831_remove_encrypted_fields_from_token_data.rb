class RemoveEncryptedFieldsFromTokenData < ActiveRecord::Migration
  def change
    remove_column :token_data, :encrypted_access_token, :string
    remove_column :token_data, :encrypted_access_token_iv, :string
    remove_column :token_data, :encrypted_access_token_salt, :string
    remove_column :token_data, :encrypted_refresh_token, :string
    remove_column :token_data, :encrypted_refresh_token_iv, :string
    remove_column :token_data, :encrypted_refresh_token_salt, :string
    
    add_column :token_data, :access_token, :string
    add_column :token_data, :refresh_token, :string
  end
end
