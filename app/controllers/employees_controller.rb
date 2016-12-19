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
    @employee.save

    respond_to do |format|
      format.js
    end
  end

end
