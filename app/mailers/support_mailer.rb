class SupportMailer < ApplicationMailer
  # ----------------------------------------------
  # DEFAULT SETTINGS -----------------------------
  # ----------------------------------------------
  default from: 'noreply@milosavings.com'


  # ----------------------------------------------
  # SUPPORT-TRANSFER-FAILED-NOTICE ---------------
  # ----------------------------------------------
  # email to send support when the transfer fails
  def support_transfer_failed_notice(user, roundup_amount, error)
   @roundup_amount = roundup_amount
   @error = error
   @user = user
   mail(to: 'robert.schwartz@milosavings.com', subject: "Transfer Failed for #{@user.email}")
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
   mail(to: 'robert.schwartz@milosavings.com', subject: "Dwolla Funding Source Failed for #{@user.email}")
  end

  # ----------------------------------------------
  # ADD-DWOLLA-USER-FAILED -----------------------
  # ----------------------------------------------
  # email to send support when adding a user to Dwolla fails
  def add_dwolla_user_failed(user, error)
   @error = error
   @user = user
   mail(to: 'robert.schwartz@milosavings.com', subject: "Dwolla Sign Up Failed for #{@user.email}")
  end
end
