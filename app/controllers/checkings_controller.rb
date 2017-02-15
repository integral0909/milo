# ================================================
# RUBY->CONTROLLER->CHECKINGS-CONTROLLER =========
# ================================================
class CheckingsController < ApplicationController
  include ActionView::Helpers::NumberHelper


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

        # redirect to number form if user has long_tail account
        if @user.long_tail
          redirect_to signup_bank_verify_path and return
        end

        format.html { redirect_to signup_on_demand_path, notice: 'Checking was successfully created.' }
        format.json { render :show, status: :created, location: @checking }
      else
        format.html { render :new }
        format.json { render json: @checking.errors, status: :unprocessable_entity }
      end
    end
  end

  def quick_save

    amount = params[:amount]
    amount = '20.00'
    Dwolla.quick_save(@user, number_to_currency(amount, unit:""))

    flash[:success] = "Congrats! You just saved $#{amount}. Keep it up!"

    redirect_to authenticated_root_path
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
