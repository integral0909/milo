# Plaid helper functions should be held here
module PlaidHelper

  private
  # ----------------------------------------------
  # WEEKLY-TRANSACTIONS --------------------------
  # Pull in last weeks transactions from the connected user account
  # ----------------------------------------------
  def self.weekly_transactions
    begin
      # NOTE: Uncomment when live
      # if day.saturday?
        # loop through all CHECKING accounts connected with Milo
        Checking.all.each do |ck|
          # Find user based on checking.user_id
          user = User.find(ck.user_id)
          connect_user = Argyle.plaid_client.set_user(user.plaid_access_token, ['connect'])
          # set condition to upgrade user if they do not have connect yet.
          puts connect_user.transactions.length
          
          Transaction.create_transactions(connect_user.transactions, ck.plaid_acct_id, user.id)
        end
    rescue => e
      # EMAIL: if all round up task breaks
      puts e
    end
  end

end
