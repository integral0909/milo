class Account < ActiveRecord::Base

  self.primary_key = 'plaid_acct_id'

  has_many :transactions
end
