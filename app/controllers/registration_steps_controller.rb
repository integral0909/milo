class RegistrationStepsController < Wicked::WizardController

  steps :phone_verify, :phone_confirm, :bank_connect, :on_demand

  def update
    @user = current_user
    case step
    when :phone_verify
      @user.update_attributes(user_params)
      # Create a random six digit verification code
      @user.verification_code =  100_000 + rand(1_000_000 - 100_000)
      @user.save
      to = @user.mobile_number
      # Create an instance of the Twilio class
      @twilio_client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
      # Send the message to Twilio
      @twilio_client.account.sms.messages.create(
        :from => ENV['TWILIO_PHONE_NUMBER'],
        :to => to,
        :body => "Your Milo verification code is #{@user.verification_code}."
      )
    when :phone_confirm
      @user.update_attributes(user_params)
      if @user.verification_code == params[:verification_code]
        @user.is_verified = true
        @user.verification_code = ''
        @user.save
        #   redirect_to edit_user_registration_path, :flash => { :success => "Thank you for verifying your mobile number." }
        #   return
        # else
        #   redirect_to edit_user_registration_path, :flash => { :errors => "Invalid verification code." }
        #   return
      end
    when :bank_connect
      @user.update_attributes(user_params)
    when :on_demand
      @user.update_attributes(user_params)
    end
    sign_in(@user, bypass: true) # needed for devise
    render_wizard @user
  end

  def show
    @user = current_user
    render_wizard
  end

  def finish_wizard_path
    root_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :zip, :mobile_number, :on_demand, :agreement, :verification_code, :is_verified, :invited)
  end

end
