class Account < ActiveRecord::Base

  self.primary_key = 'plaid_acct_id'

  has_many :transactions
  belongs_to :user
  belongs_to :public_token

end
