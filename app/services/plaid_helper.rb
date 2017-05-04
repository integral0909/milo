# ================================================
# RUBY->PLAID-HELPER =============================
# ================================================
# Plaid helper functions should be held here
# TODO :: should this be in /helpers instead of /services ?
module PlaidHelper

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # CREATE-WEEKLY-TRANSACTIONS -------------------
  # ----------------------------------------------
  # Pull in last weeks transactions from the connected user account
  def self.create_weekly_transactions(user, checking)
    tuesday = set_tuesday
    begin
      # Pull in plaid connect user
      connect_user = Plaid::User.load(:connect, user.plaid_access_token)
      user_transactions = connect_user.transactions()

      # filter transactions to the ones that match the users checking and this past week
      current_transactions = user_transactions.select{|a| (a.account_id == checking.plaid_acct_id) && (a.date.to_date >= tuesday)}

      # create the transactions
      Transaction.create_transactions(current_transactions, checking.plaid_acct_id, user.id)
    rescue => e
      # EMAIL: email if creating the weekly transactions task breaks
      puts e
    end
  end

  # ----------------------------------------------
  # CURRENT-WEEK-TRANSACTIONS --------------------
  # ----------------------------------------------
  # Pull in current weeks transactions from the connected user account and send to the view
  # user : current_user that is logged in
  # checking : Checking account connected to the current_user
  # return : array of transaction objects for the view
  def self.current_week_transactions(user, checking)
    if user && checking
      begin
        # set date to beginning of the week
        tuesday = set_tuesday

        # Pull in plaid connect user
        # upgrade to connect_user = Plaid::User.load(:connect, user.plaid_access_token) when upgrading to the most recent API
        connect_user = Plaid::User.load(:connect, user.plaid_access_token)
        user_transactions = connect_user.transactions()

        # filter transactions to the ones that match the users checking and are only from the current week
        current_transactions = user_transactions.select{|a| (a.account_id == checking.plaid_acct_id) && (a.date.to_date >= tuesday)}

        # create transaction objects for the view
        transactions_for_view = current_transactions.map { |tr| {roundup: round_transaction(tr.amount), trans_name: tr.name, amount: tr.amount} }

        return transactions_for_view
      rescue

      end
    end
  end

  # ----------------------------------------------
  # ROUND-TRANSACTIONS ---------------------------
  # ----------------------------------------------
  # Set the amount that we would round up for the transaction shown
  # amount : transaction amount
  # return : amount we are going to round up
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
  # SET-MONDAY -----------------------------------
  # ----------------------------------------------
  # Set the previous Monday's date
  def self.set_tuesday
    current_date = Date.today
    tuesday = current_date.beginning_of_week(start_day = :tuesday)
  end

  # check balance of connected account before pulling round ups
  def self.check_balance(user, checking)
    # checking = Checking.find_by_user_id(user.id)
    connect_user = Plaid::User.load(:connect, user.plaid_access_token)

    # pull in updated balance
    acct_balances = connect_user.balance

    # find index of account in array
    acct_index = acct_balances.index {|a| a.id == checking.plaid_acct_id}

    # return account balace of connected account
    balance = acct_balances[acct_index].available_balance
  end

end
