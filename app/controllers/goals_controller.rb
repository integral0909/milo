# ================================================
# RUBY->CONTROLLER->GOALS-CONTROLLER =============
# ================================================
class GoalsController < ApplicationController

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  before_action :authenticate_user!

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # CREATE ---------------------------------------
  # ----------------------------------------------
  def create
    @goal = current_user.goals.build(goal_params)
    if @goal.save
      flash[:success] = "Goal was successfully created!"
      redirect_to authenticated_root_path
    else
      render 'home/index'
    end
  end

  # ----------------------------------------------
  # EDIT ---------------------------------------
  # ----------------------------------------------
  def update
    @goal = Goal.find(params[:id])
    @goal.update(goal_params)
    if @goal.save
      if @goal.completed
        flash[:success] = "Goal was successfully completed!"
      else
        flash[:success] = "Goal was successfully saved!"
      end
      redirect_to authenticated_root_path
    else
      render 'home/index'
    end
  end

  # ----------------------------------------------
  # DESTROY --------------------------------------
  # ----------------------------------------------
  # After destroy reset split for remaining goals
  def destroy
    @goal.destroy
    @goal.set_goal_split
    flash[:success] = "Goal was successfully deleted."
    redirect_to request.referrer || authenticated_root_path
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # GOAL-PARAMS ----------------------------------
  # ----------------------------------------------
  def goal_params
    params.require(:goal).permit(:name, :description, :amount, :completed, :active, :gtype, :percentage, :balance, :preset)
  end

end
