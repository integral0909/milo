# ================================================
# RUBY->CONTROLLER->EMPLOYEES-CONTROLLER =========
# ================================================
class EmployeesController < ApplicationController

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # INDEX ----------------------------------------
  # ----------------------------------------------
  def index
    @employees = User.where(business_id: current_user.business_id).all
  end

  # ----------------------------------------------
  # DESTROY --------------------------------------
  # ----------------------------------------------
  def destroy
    @employee = User.find(params[:id])
    @employee.business_id = nil
    # skip validations incase there is an issue on the user object (ex: they haven't fully signed up)
    @employee.save(validate: false)

    respond_to do |format|
      format.js
    end
  end

end
