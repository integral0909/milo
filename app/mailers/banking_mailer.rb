# ================================================
# RUBY->BANKING-MAILER ===========================
# ================================================
class BankingMailer < ApplicationMailer

  # ----------------------------------------------
  # DEFAULT SETTINGS -----------------------------
  # ----------------------------------------------
  default from: 'noreply@milosavings.com'

  # ----------------------------------------------
  # ACCOUNT-ADDED --------------------------------
  # ----------------------------------------------
  # email to send user when the Dwolla transfer starts
  def account_added(user, funding_account)
   @funding_account = funding_account
   @user = user
   mail(to: @user.email, subject: 'You Are Now Connected!')
  end

  # ----------------------------------------------
  # ACCOUNT-ERROR-ON-ADD -------------------------
  # ----------------------------------------------
  # email to send user when the Dwolla transfer starts
  def account_error_on_add(user, funding_account)
   @funding_account = funding_account
   @user = user
   mail(to: @user.email, subject: 'Your Transfer Has Started')
  end

  # ----------------------------------------------
  # TRANSFER-START -------------------------------
  # ----------------------------------------------
  # email to send user when the Dwolla transfer starts
  def transfer_start(user, roundup_amount, funding_account)
    puts "transfer start"
   @roundup_amount = roundup_amount
   @funding_account = find_account(funding_account)
   @user = user
   mail(to: @user.email, subject: 'Your Transfer Has Started')
  end

  # ----------------------------------------------
  # TRANSFER-SUCCESS -----------------------------
  # ----------------------------------------------
  # email to send user when the transfer was successful
  def transfer_success(user, roundup_amount, funding_account)
    puts "Round Up Success"
   @roundup_amount = roundup_amount
   @funding_account = find_account(funding_account)
   @user = user
   mail(to: @user.email, subject: 'Success! You Just Saved Some Cash!')
  end

  # ----------------------------------------------
  # TRANSFER-FAILED ------------------------------
  # ----------------------------------------------
  # email to send user when the transfer fails
  def transfer_failed(user, roundup_amount, funding_account)
    puts "Round Up Failed"
   @roundup_amount = roundup_amount
   @funding_account = find_account(funding_account)
   @user = user
   mail(to: @user.email, bcc: 'robert.schwartz@milosavings.com', subject: 'Transfer to Savings Failed')
  end

  # email to send support when the transfer fails
  def support_transfer_failed_notice(user, roundup_amount, error)
   @roundup_amount = roundup_amount
   @error = error
   @user = user
   mail(to: 'robert.schwartz@milosavings.com', subject: "Transfer Failed for #{@user.email}")
  end

  # ----------------------------------------------
  # BANK-ACCOUNT-REMOVED -------------------------
  # ----------------------------------------------
  # email to send user when they remove a bank account
  def bank_account_removed(user, funding_account)
   @user = user
   @funding_account = find_account(funding_account)
   mail(to: @user.email, subject: 'Bank Account Successfully Removed')
  end

  # ----------------------------------------------
  # TRANSFER-START-EMPLOYER ----------------------
  # ----------------------------------------------
  # TODO :: email to send employer when transfer has started for employees.
  def transfer_start_employer(user)
   @user = user
   mail(to: @user.email, subject: 'Welcome to Milo!')
  end

  # ----------------------------------------------
  # FIND-ACCOUNT ---------------------------------
  # ----------------------------------------------
  def find_account(funding_account)
    return Account.find_by_plaid_acct_id(funding_account.plaid_acct_id)
  end

end
