class VerificationsController < ApplicationController

  def create
    # Create a random six digit verification code
    current_user.verification_code =  1_000_000 + rand(10_000_000 - 1_000_000)
    current_user.save
    # If the number starts with 0 add country code in front
    to = current_user.mobile_number
    # if to[0] = "0"
    #   to.sub!("0", '+1')
    # end
    # Create an instance of the Twilio class
    @twilio_client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
    # Send the message to Twilio
    @twilio_client.account.sms.messages.create(
      :from => ENV['TWILIO_PHONE_NUMBER'],
      :to => to,
      :body => "#{current_user.verification_code} is your Milo phone verification code."
    )
    # Redirect back to the edit profile page
    redirect_to edit_user_registration_path, :flash => { :success => "A verification code has been sent to your phone. Please fill it in below." }
    return
  end

  def verify
    if current_user.verification_code == params[:verification_code]
      current_user.is_verified = true
      current_user.verification_code = ''
      current_user.save
      redirect_to edit_user_registration_path, :flash => { :success => "Thank you for verifying your mobile number." }
      return
    else
      redirect_to edit_user_registration_path, :flash => { :errors => "Invalid verification code." }
      return
    end
  end

end
