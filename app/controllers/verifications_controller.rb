# ================================================
# RUBY->CONTROLLER->VERIFICATIONS-CONTROLLER =====
# ================================================
class VerificationsController < ApplicationController

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # CREATE ---------------------------------------
  # ----------------------------------------------
  def create
    begin
      current_user.mobile_number = params[:mobile_number]
      # Create a random six digit verification code
      current_user.verification_code = 100_000 + rand(1_000_000 - 100_000)
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
      redirect_to signup_phone_confirm_path
      return
    rescue
      redirect_to signup_phone_path, :flash => { :alert => "Please enter a valid phone number." }
      return
    end
  end

  # ----------------------------------------------
  # VERIFY ---------------------------------------
  # ----------------------------------------------
  def verify
    if current_user.verification_code == params[:verification_code]
      current_user.is_verified = true
      current_user.verification_code = ''
      current_user.save
      redirect_to user_accounts_path(current_user)
      return
    else
      redirect_to signup_phone_confirm_path, :flash => { :alert => "Invalid verification code." }
      return
    end
  end

end
