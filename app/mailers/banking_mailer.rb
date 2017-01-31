# ================================================
# RUBY->BANKING-MAILER ===========================
# ================================================
class BankingMailer < ApplicationMailer

  # ----------------------------------------------
  # DEFAULT SETTINGS -----------------------------
  # ----------------------------------------------
  default from: 'noreply@shiftsavings.com'

  # ----------------------------------------------
  # ACCOUNT-ADDED --------------------------------
  # ----------------------------------------------
  # email to send user when the account is successfully added
  def account_added(user, funding_account)
   @funding_account = funding_account
   @user = user
   mail(to: @user.email, subject: 'You are now connected with Shift!')
  end

  # ----------------------------------------------
  # LONGTAIL-ACCOUNT-ADDED --------------------------------
  # ----------------------------------------------
  # email to send user when the user connects an account that needs micro-deposit verification
  def longtail_account_added(user, funding_account)
   @funding_account = funding_account
   @user = user
   mail(to: @user.email, subject: 'Verify you bank account on Shift.')
  end

  # ----------------------------------------------
  # TRANSFER-START -------------------------------
  # ----------------------------------------------
  # email to send user when the Dwolla transfer starts
  def transfer_start(user, roundup_amount, funding_account, tech_fee_charged)
    puts "transfer start"
   @roundup_amount = roundup_amount
   @funding_account = find_account(funding_account)
   @user = user
   @tech_fee_charged = tech_fee_charged
   mail(to: @user.email, subject: 'Your Shift transfer has started.')
  end

  # ----------------------------------------------
  # WITHDRAW-START -------------------------------
  # ----------------------------------------------
  # email to send user when the Dwolla transfer starts
  def withdraw_start(user, roundup_amount, funding_account)
    puts "withdraw started"
   @roundup_amount = roundup_amount
   @funding_account = find_account(funding_account)
   @user = user
   mail(to: @user.email, subject: 'Your Shift withdrawal has started.')
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
   mail(to: @user.email, subject: 'Success! You just saved some cash with Shift.')
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
   mail(to: @user.email, bcc: 'dev@shiftsavings.com', subject: 'Transfer to Shift failed.')
  end

  # ----------------------------------------------
  # BANK-ACCOUNT-REMOVED -------------------------
  # ----------------------------------------------
  # email to send user when they remove a bank account
  def bank_account_removed(user, funding_account)
   @user = user
   @funding_account = find_account(funding_account)
   mail(to: @user.email, subject: 'Bank account successfully removed from Shift.')
  end

  # ----------------------------------------------
  # TECH-FEE-CHARGED -----------------------------
  # email to send when the tech fee is charged
  # ----------------------------------------------
  def tech_fee_charged(total_fees_collected)
   @fees_collected = total_fees_collected
   mail(to:'finance@shiftsavings.com', bcc: 'admin@shiftsavings.com', subject: 'Shift Technology Fees Report')
  end

  # ----------------------------------------------
  # BIZ-TECH-FEE-SUCCESS -------------------------
  # ----------------------------------------------
  # email to send user when the transfer was successful
  def biz_tech_fee_success(user, fee_charged)
    puts "Biz tech fee charged"
   @fee_charged = fee_charged
   @user = user
   mail(to: @user.email, subject: 'Automatic Transfer Successful for Milo')
  end

  # ----------------------------------------------
  # BIZ-TECH-FEE-FAILED -------------------------
  # ----------------------------------------------
  # email to send user when the transfer was successful
  def biz_tech_fee_failed(user, fee_charged)
    puts "Biz tech fee charged"
   @fee_charged = fee_charged
   @user = user
   mail(to: @user.email, subject: 'Automatic Transfer Failed for Milo')
  end

  # ----------------------------------------------
  # TRANSFER-START-EMPLOYER ----------------------
  # ----------------------------------------------
  # TODO :: email to send employer when transfer has started for employees.
  def transfer_start_employer(user)
   @user = user
   mail(to: @user.email, subject: 'Welcome to Shift!')
  end

  # ----------------------------------------------
  # Email for successful business contribution withdraw
  # ----------------------------------------------
  def biz_contributions_successful(biz, biz_owner, contribution)
   @biz = biz
   @contribution = contribution
   @owner = biz_owner
   mail(to: @owner.email, subject: 'Contributions have been sent!')
  end

  # ----------------------------------------------
  # Email for failed business contribution withdraw
  # ----------------------------------------------
  def biz_contributions_failed(biz, biz_owner, contribution)
   @biz = biz
   @contribution = contribution
   @owner = biz_owner
   mail(to: @owner.email, subject: 'Emplyoee Contributions Failed for Milo!')
  end

  # ----------------------------------------------
  # FIND-ACCOUNT ---------------------------------
  # ----------------------------------------------
  def find_account(funding_account)
    return Account.find_by_plaid_acct_id(funding_account.plaid_acct_id)
  end

end
