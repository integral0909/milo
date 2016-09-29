class Transactions
  # recieve a total of all transations from each user
  def self.weekly_roundup
    # loop through all CHECKING accounts connected with Milo
    Checking.all.each do |ck|
      # Find user based on checking.user_id
      @user = User.find(ck.user_id)
      # find all transactions where transaction.account_id = ck.plaid_acct_id & pending = false OR transaction.user_id once it's added && within the last week
      @transactions = Transaction.where(account_id == ck.plaid_acct_id && pending == false)
      ####### total the roundups
      # set variable for roundup_total
      @roundup_total = 0
      # go through transactions and add transaction.roundup to the total
      @transactions.each do |trns|
        @round += trns.roundup
      end

      # account = Account.where(plaid_acct_id = ck.plaid_acct_id) should be 1
      @account = Account.where(plaid_acct_id == ck.plaid_acct_id)
      @checking_acct_number = @account.account_number
      @checking_routing_number @acount.number
      # grab the account number of the checking and routing number from account found with account.numbers (routing) & account.account_number
      # send the total amount to Dwolla
      # on success => update the transaction with roundup 0.00 or rounded up. Also update total roundups on the user -> this will be where we know how much they have in their account.

      # send email to user with weekly data and how much they have in their account
    end
  end
end
