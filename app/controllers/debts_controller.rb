class DebtsController < ApplicationController

  # ----------------------------------------------
  # INCLUDES -------------------------------------
  # ----------------------------------------------
  include ActionView::Helpers::NumberHelper

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  before_action :authenticate_user!
  before_action :set_debt, only: [:show, :edit, :update, :destroy]

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # INDEX ----------------------------------------
  # ----------------------------------------------
  def index
    @debts = Debt.where(user_id: current_user.id).all
  end

  # ----------------------------------------------
  # SHOW -----------------------------------------
  # ----------------------------------------------
  def show
  end

  # ----------------------------------------------
  # NEW ------------------------------------------
  # ----------------------------------------------
  def new
    @debt = Debt.new
  end

  # ----------------------------------------------
  # EDIT -----------------------------------------
  # ----------------------------------------------
  def edit
  end

  # ----------------------------------------------
  # CREATE ---------------------------------------
  # ----------------------------------------------
  def create
    @debt = Debt.new(debt_params)

    respond_to do |format|
      if @debt.save
        format.html { redirect_to @debt, notice: 'Debt was successfully created.' }
        format.json { render :show, status: :created, location: @debt }
      else
        format.html { render :new }
        format.json { render json: @debt.errors, status: :unprocessable_entity }
      end
    end
  end

  # ----------------------------------------------
  # UPDATE ---------------------------------------
  # ----------------------------------------------
  def update
    respond_to do |format|
      if @debt.update(debt_params)
        format.html { redirect_to @debt, notice: 'Debt was successfully updated.' }
        format.json { render :show, status: :ok, location: @debt }
      else
        format.html { render :edit }
        format.json { render json: @debt.errors, status: :unprocessable_entity }
      end
    end
  end

  # ----------------------------------------------
  # DESTROY --------------------------------------
  # ----------------------------------------------
  def destroy
    @debt.destroy
    respond_to do |format|
      format.html { redirect_to debts_url, notice: 'Debt was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

    # --------------------------------------------
    # SET-DEBT -----------------------------------
    # --------------------------------------------
    def set_debt
      @debt = Debt.find(params[:id])
    end

    # --------------------------------------------
    # DEBT-PARAMS --------------------------------
    # --------------------------------------------
    def debt_params
      params.require(:debt).permit(:user_id, :account_name, :account_number, :debt_type, :begin_balance, :current_balance, :minimum_payment, :credit_limit, :apr, :user_id, :created_at, :updated_at, :due_date)
    end

end
