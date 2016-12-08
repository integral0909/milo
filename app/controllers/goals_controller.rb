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
      flash[:success] = "Goal created!"
      redirect_to root_path
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
        Goal.mark_as_completed(@goal)
      end
      flash[:success] = "Goal Saved!"
      redirect_to root_path
    else
      render 'home/index'
    end
  end

  # ----------------------------------------------
  # DESTROY --------------------------------------
  # ----------------------------------------------
  def destroy
    @goal.destroy
    flash[:success] = "Goal deleted"
    redirect_to request.referrer || root_path
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # GOAL-PARAMS ----------------------------------
  # ----------------------------------------------
  def goal_params
    params.require(:goal).permit(:name, :description, :amount, :completed, :active)
  end

end
