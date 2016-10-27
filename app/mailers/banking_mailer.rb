# Email notifications for any banking items in the application

class BankingMailer < ApplicationMailer
  default from: 'noreply@milosavings.com'

  # email to send user when the Dwolla transfer starts
  def account_added(user, funding_account)
   @funding_account = funding_account
   @user = user
   mail(to: @user.email, subject: 'You Are Now Connected!')
  end

  # email to send user when the Dwolla transfer starts
  def account_error_on_add(user, funding_account)
   @funding_account = funding_account
   @user = user
   mail(to: @user.email, subject: 'Your Transfer Has Started')
  end

  # email to send user when the Dwolla transfer starts
  def transfer_start(user, roundup_amount, funding_account)
    puts "start"
   @roundup_amount = roundup_amount
   @funding_account = find_account(funding_account)
   @user = user
   mail(to: @user.email, subject: 'Your Transfer Has Started')
  end

  # email to send user when the transfer was successful
  def transfer_success(user, roundup_amount, funding_account)
    puts "success"
   @roundup_amount = roundup_amount
   @funding_account = find_account(funding_account)
   @user = user
   mail(to: @user.email, subject: 'Success! You Just Saved Some Cash!')
  end

  # email to send user when the transfer fails
  def transfer_failed(user, roundup_amount, funding_account)
    puts "failed"
   @roundup_amount = roundup_amount
   @funding_account = find_account(funding_account)
   @user = user
   mail(to: @user.email, subject: 'Transfer to Savings Failed')
  end

  # email to send user when they remove a bank account
  def bank_account_removed(user, funding_account)
   @user = user
   @funding_account = find_account(funding_account)
   mail(to: @user.email, subject: 'Bank Account Successfully Removed')
  end

  # email to send employer when transfer has started for employees. FUTURE DEV
  def transfer_start_employer(user)
   @user = user
   mail(to: @user.email, subject: 'Welcome to Milo!')
  end

  def find_account(funding_account)
    return Account.find_by_plaid_acct_id(funding_account.plaid_acct_id)
  end


end
