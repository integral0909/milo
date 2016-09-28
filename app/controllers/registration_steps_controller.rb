class RegistrationStepsController < Wicked::WizardController

  steps :phone_verify, :phone_confirm

  def update
    @user = current_user
    case step
    when :phone_confirm
        @user.update_attributes(user_params)
      when :phone_verify
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
    params.require(:user).permit(:name, :email, :password, :zip)
  end

end
