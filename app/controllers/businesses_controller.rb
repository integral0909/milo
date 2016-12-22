# ================================================
# RUBY->CONTROLLER->BUSINESSES-CONTROLLER ========
# ================================================
class BusinessesController < ApplicationController

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  before_action :set_business, only: [:edit, :update]

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # EDIT -----------------------------------------
  # ----------------------------------------------
  def edit
  end

  # ----------------------------------------------
  # UPDATE ---------------------------------------
  # ----------------------------------------------
  def update
    respond_to do |format|
      if @business.update(business_params)
        format.html { redirect_to edit_business_path(@business), notice: 'Business was successfully updated.' }
        format.json { render :edit, status: :ok, location: @business }
      else
        format.html { render :edit }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # SET-BUSINESS ---------------------------------
  # ----------------------------------------------
  def set_business
    @business = Business.find(@user.business_id)
  end

  # ----------------------------------------------
  # BUSINESS-PARAMS ------------------------------
  # ----------------------------------------------
  def business_params
    params.require(:business).permit(:name, :contribution, :frequency)
  end

end
