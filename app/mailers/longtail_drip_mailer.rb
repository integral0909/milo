# ================================================
# RUBY->LONGTAIL-DRIP-MAILER =====================
# ================================================
class LongtailDripMailer < ApplicationMailer

  include Resque::Mailer

  # ----------------------------------------------
  # DEFAULT SETTINGS -----------------------------
  # ----------------------------------------------
  default from: 'noreply@shiftsavings.com'

  # ----------------------------------------------
  # LONGTAIL-DRIP-1 ------------------------------
  # ----------------------------------------------
  # Send 3 days after sign up
  def longtail_drip_1(user_id, funding_account_id)
    @user = User.find_by_id(user_id)
    @funding_account = Account.find_by_plaid_acct_id(funding_account_id)
    mail(to: @user.email, subject: "Please verify your bank account on Shift.")
  end

  # ----------------------------------------------
  # LONGTAIL-DRIP-2 ------------------------------
  # ----------------------------------------------
  # Send 5 days after sign up
  def longtail_drip_2(user_id, funding_account_id)
    @user = User.find_by_id(user_id)
    @funding_account = Account.find_by_plaid_acct_id(funding_account_id)
    mail(to: @user.email, subject: "Did you verify you bank account on Shift?")
  end

  # ----------------------------------------------
  # LONGTAIL-DRIP-3 ------------------------------
  # ----------------------------------------------
  # Send 7 days after sign up
  def longtail_drip_3(user_id, funding_account_id)
    @user = User.find_by_id(user_id)
    @funding_account = Account.find_by_plaid_acct_id(funding_account_id)
    mail(to: @user.email, subject: "Confirm your bank account now.")
  end

  # ----------------------------------------------
  # LONGTAIL-DRIP-4 ------------------------------
  # ----------------------------------------------
  # Send 12 days after sign up
  def longtail_drip_4(user_id, funding_account_id)
    @user = User.find_by_id(user_id)
    @funding_account = Account.find_by_plaid_acct_id(funding_account_id)
    mail(to: @user.email, subject: "Last chance to verify your bank account on Shift!")
  end

end
