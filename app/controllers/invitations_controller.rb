# ================================================
# RUBY->CONTROLLER->INVITATIONS-CONTROLLER =======
# ================================================
class InvitationsController < Devise::InvitationsController

  # ----------------------------------------------
  # LAYOUT ---------------------------------------
  # ----------------------------------------------
  layout "signup"

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # INVITE-PARAMS --------------------------------
  # ----------------------------------------------
  def invite_params
    super.merge(business_id: current_user.business_id, invited: true)
  end

  # ----------------------------------------------
  # RESOURCE-PARAMS ------------------------------
  # ----------------------------------------------
  def resource_params
    params.permit(user: [:name, :email, :invitation_token, :phone, :address, :city, :state, :zip])[:user]
  end

end
