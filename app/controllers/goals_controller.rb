class GoalsController < ApplicationController

  before_action :authenticate_user!

  def create
    @goal = current_user.goals.build(goal_params)
    if @goal.save
      flash[:success] = "Goal created!"
      redirect_to root_path
    else
      render 'home/index'
    end
  end

  def destroy
    @goal.destroy
    flash[:success] = "Goal deleted"
    redirect_to request.referrer || root_path
  end

  private

  def goal_params
    params.require(:goal).permit(:name, :description, :amount)
  end

end
