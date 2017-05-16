class SupportMailer < ApplicationMailer
  
  # ----------------------------------------------
  # DEFAULT SETTINGS -----------------------------
  # ----------------------------------------------
  default from: 'noreply@shiftsavings.com'

  # ----------------------------------------------
  # SUPPORT-TRANSFER-FAILED-NOTICE ---------------
  # ----------------------------------------------
  # email to send support when the transfer fails
  def support_transfer_failed_notice(user, roundup_amount, error)
   @roundup_amount = roundup_amount
   @error = error
   @user = user
   mail(to: 'dev@shiftsavings.com', subject: "Transfer Failed for #{@user.email}")
  end

  # ----------------------------------------------
  # USER-WITHDRAW-FAILED -------------------------
  # ----------------------------------------------
  # email to send support when the transfer fails
  def user_withdraw_failed(user, roundup_amount, error)
   @roundup_amount = roundup_amount
   @error = error
   @user = user
   mail(to: 'dev@shiftsavings.com', subject: "User Withdraw Failed for #{@user.email}")
  end

  # ----------------------------------------------
  # SUPPORT-DWOLLA-FAILED-NOTICE ---------------
  # ----------------------------------------------
  # email to send support when the transfer fails
  def connect_funding_source_failed(user, user_checking, funding_account, error)
   @user_checking = user_checking
   @funding_account = funding_account
   @error = error
   @user = user
   mail(to: 'dev@shiftsavings.com', subject: "Dwolla Funding Source Failed for #{@user.email}")
  end

  # ----------------------------------------------
  # ADD-DWOLLA-USER-FAILED -----------------------
  # ----------------------------------------------
  # email to send support when adding a user to Dwolla fails
  def add_dwolla_user_failed(user, error)
    @error = error
    @user = user
    mail(to: 'dev@shiftsavings.com', subject: "Dwolla Sign Up Failed for #{@user.email}")
  end

  # ----------------------------------------------
  # ADD-DWOLLA-USER-FAILED -----------------------
  # ----------------------------------------------
  # email to send support when adding a user to Dwolla fails
  def support_biz_contributions_failed(biz, contribution, error)
    @error = error
    @biz = biz
    @contribution = contribution
    @user = User.find(biz.owner)
    mail(to: 'dev@shiftsavings.com', subject: "Contributions failed for #{@biz.name}")
  end

  # ----------------------------------------------
  # Quick save failed ----------------------------
  # ----------------------------------------------
  # email to send support when adding a user to Dwolla fails
  def quick_save_failed(user, amount, error)
    @error = error
    @amount = amount
    @user = user
    mail(to: 'dev@shiftsavings.com', subject: "Quick Save failed for #{@user.email}")
  end

  # ----------------------------------------------
  # Dwolla webhook failed ----------------------------
  # ----------------------------------------------
  # email to send support when dwolla webhook process fails
  def dwolla_webhook_failed(event, error)
    @error = error
    @event_id = event.id
    mail(to: 'dev@shiftsavings.com', subject: "Dwolla Webhook Failed")
  end

  # ----------------------------------------------
  # Dwolla webhook failed ----------------------------
  # ----------------------------------------------
  # email to send support when dwolla webhook process fails
  def bank_transfer_failed(event, error)
    @error = error
    @event_id = event.id
    mail(to: 'dev@shiftsavings.com', subject: "Bank Transfer Failed")
  end

  # ----------------------------------------------
  # Dwolla webhook failed ----------------------------
  # ----------------------------------------------
  # email to send support when there is a basic error in the application
  def basic_error(error)
    @error = error
    mail(to: 'dev@shiftsavings.com', subject: "Application Error")
  end
end
