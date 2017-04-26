# ================================================
# RUBY->CONTROLLER->PASSWORDS-CONTROLLER =========
# ================================================
class PasswordsController < Devise::PasswordsController

  respond_to :json, :html

  # ----------------------------------------------
  # LAYOUT ---------------------------------------
  # ----------------------------------------------
  layout "signup"

end
