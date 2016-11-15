# ================================================
# RUBY->USER-MAILER ==============================
# ================================================
class UserMailer < ApplicationMailer

  # ----------------------------------------------
  # VARIABLES ------------------------------------
  # ----------------------------------------------
  BASE_URL = "http://milosavings.com?referral="

  # ----------------------------------------------
  # DEFAULT SETTINGS -----------------------------
  # ----------------------------------------------
  default from: 'noreply@milosavings.com'

  # ----------------------------------------------
  # WELCOME-EMAIL --------------------------------
  # ----------------------------------------------
  def welcome_email(user)
    @referral_link = Bitly.client.shorten(BASE_URL + user.id.to_s).short_url
    @user = user
    @url  = 'https://milosavings.com'
    mail(to: @user.email, subject: 'Welcome to Milo!')
  end
end
