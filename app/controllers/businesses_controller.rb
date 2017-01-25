# ================================================
# RUBY->CONTROLLER->BUSINESSES-CONTROLLER ========
# ================================================
class BusinessesController < ApplicationController

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  # before_action :set_business, only: [:edit, :update]

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # EDIT -----------------------------------------
  # ----------------------------------------------
  def edit
    if @biz
      @frequency_options = ["Weekly", "Bi-Monthly", "Monthly", "Quarterly", "Yearly"]
    else
      flash[:alert] = "Oops, looks like you don't have access to that page."
      redirect_to root_path
    end
  end

  # ----------------------------------------------
  # UPDATE ---------------------------------------
  # ----------------------------------------------
  def update
    respond_to do |format|
      if @biz.update(business_params)
        format.html { redirect_to settings_contributions_path, notice: 'Business was successfully updated.' }
        format.json { render :contribution_settings, status: :ok, location: @biz }
      else
        format.html { render :contribution_settings }
        format.json { render json: @biz.errors, status: :unprocessable_entity }
      end
    end
  end

  def contribution_settings
    @frequency_options = ["Weekly", "Bi-Monthly", "Monthly", "Quarterly", "Yearly"]
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private
  #
  # # ----------------------------------------------
  # # SET-BUSINESS ---------------------------------
  # # ----------------------------------------------
  # def set_business
  #   @business = Business.find(@user.business_id)
  # end

  # ----------------------------------------------
  # BUSINESS-PARAMS ------------------------------
  # ----------------------------------------------
  def business_params
    params.require(:business).permit(:name, :max_contribution, :match_percent, :frequency)
  end

end
