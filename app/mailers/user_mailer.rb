class UserMailer < ApplicationMailer
  BASE_URL = "http://milosavings.com?referral="
  default from: 'Welcome@milosavings.com'

  def welcome_email(user)
   @referral_link = Bitly.client.shorten(BASE_URL + user.id.to_s).short_url
   @user = user
   @url  = 'https://milosavings.com'
   mail(to: @user.email, subject: 'Welcome to Milo!')
  end
end
