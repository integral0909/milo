class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email(user)
   @user = user
   @url  = 'https://milosavings.com'
   mail(to: @user.email, subject: 'Welcome to Milo!')
  end
end
