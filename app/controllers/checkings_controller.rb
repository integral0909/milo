# ================================================
# RUBY->CONTROLLER->CHECKINGS-CONTROLLER =========
# ================================================
class CheckingsController < ApplicationController

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # NEW ------------------------------------------
  # ----------------------------------------------
  def new
    @checking = Checking.new
    @accounts = Account.where(user_id: current_user.id, acct_subtype: "checking")

    render layout: "signup"
  end

  # ----------------------------------------------
  # CREATE ---------------------------------------
  # ----------------------------------------------
  def create
    @checking = Checking.new(checking_params)

    respond_to do |format|
      if @checking.save
        format.html { redirect_to signup_on_demand_path, notice: 'Checking was successfully created.' }
        format.json { render :show, status: :created, location: @checking }
      else
        format.html { render :new }
        format.json { render json: @checking.errors, status: :unprocessable_entity }
      end
    end
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # CHECKING-PARAMS ------------------------------
  # ----------------------------------------------
  def checking_params
    params.require(:checking).permit(:user_id, :plaid_acct_id)
  end

end
