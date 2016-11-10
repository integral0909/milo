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

  # ----------------------------------------------
  # CURRENT-WEEK-TRANSACTIONS -------------------
  # Pull in current weeks transactions from the connected user account and send to the view
  # user : current_user that is logged in
  # checking : Checking account connected to the current_user
  # return : array of transaction objects for the view
  # ----------------------------------------------
  def self.current_week_transactions(user, checking)
    if user && checking
      # set date to beginning of the week
      sunday = set_sunday

      # Pull in plaid connect user
      connect_user = Argyle.plaid_client.set_user(user.plaid_access_token, ['connect'])
      user_transactions = connect_user.transactions()

      # filter transactions to the ones that match the users checking and are only from the current week
      current_transactions = user_transactions.select{|a| (a.account == checking.plaid_acct_id) && (a.date.to_date >= sunday)}

      # create transaction objects for the view
      transactions_for_view = current_transactions.map { |tr| {roundup: round_transaction(tr.amount), trans_name: tr.name, amount: tr.amount} }

      return transactions_for_view
    end
  end

  # ----------------------------------------------
  # ROUND-TRANSACTIONS -------------------
  # Set the amount that we would round up for the transaction shown
  # amount : transaction amount
  # return : amount we are going to round up
  # ----------------------------------------------
  def self.round_transaction(amount)
    new_amount = amount.ceil

    if new_amount > 0.00
      subtract = new_amount - amount

      subtract == 0 ? 1.00 : subtract.round(2)
    else
      0.00
    end
  end

  # ----------------------------------------------
  # SET-SUNDAY -------------------
  # Set the previous Sunday's date
  # ----------------------------------------------
  def self.set_sunday
    current_date = Date.today
    sunday = current_date.beginning_of_week(start_day = :sunday)
  end

end
