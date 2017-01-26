# ================================================
# RUBY->USER-MAILER ==============================
# ================================================
class UserMailer < ApplicationMailer

  # ----------------------------------------------
  # VARIABLES ------------------------------------
  # ----------------------------------------------
  BASE_URL = "https://bank.shiftsavings.com?referral="

  # ----------------------------------------------
  # DEFAULT SETTINGS -----------------------------
  # ----------------------------------------------
  default from: 'noreply@shiftsavings.com'

  # ----------------------------------------------
  # WELCOME-EMAIL --------------------------------
  # ----------------------------------------------
  def welcome_email(user)
    @referral_link = Bitly.client.shorten(BASE_URL + user.id.to_s).short_url
    @user = user
    @url  = 'https://bank.shiftsavings.com'
    mail(to: @user.email, subject: 'Welcome to Shift!')
  end
end
