class RegistrationStepsController < Wicked::WizardController

  steps :phone_verify, :phone_confirm, :bank_connect, :on_demand

  def update
    @user = current_user
    case step
    when :phone_verify
      @user.update_attributes(user_params)
      # Create a random six digit verification code
      @user.verification_code =  1_000_000 + rand(10_000_000 - 1_000_000)
      @user.save
      # If the number starts with 0 add country code in front
      to = @user.mobile_number
      # if to[0] = "0"
      #   to.sub!("0", '+1')
      # end
      # Create an instance of the Twilio class
      @twilio_client = Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_TOKEN']
      # Send the message to Twilio
      @twilio_client.account.sms.messages.create(
        :from => ENV['TWILIO_PHONE_NUMBER'],
        :to => to,
        :body => "#{@user.verification_code} is your Milo phone verification code."
      )
    when :phone_confirm
      @user.update_attributes(user_params)
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
    params.require(:user).permit(:name, :email, :password, :zip, :mobile_number)
  end

end
