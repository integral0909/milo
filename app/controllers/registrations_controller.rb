class RegistrationsController < Devise::RegistrationsController

  private

  def sign_up_params
    params.require(:user).permit(:referral_code, :email, :password, :password_confirmation)
  end

end
