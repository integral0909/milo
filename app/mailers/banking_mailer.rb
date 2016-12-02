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
  def transfer_success(user, roundup_amount, funding_account, tech_fee_charged)
    puts "Round Up Success"
   @roundup_amount = roundup_amount
   @funding_account = find_account(funding_account)
   @user = user
   @tech_fee_charged = tech_fee_charged
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
  # TECH-FEE-CHARGED -----------------------------
  # email to send when the tech fee is charged
  # ----------------------------------------------
  def tech_fee_charged(total_fees_collected)
   @fees_collected = total_fees_collected
   mail(to:'tom.wondra@milosavings.com', bcc: 'admin@milosavings.com', subject: 'Tech Fees Have Been Charged')
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
