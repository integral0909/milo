require 'test_helper'

class GoalsControllerTest < ActionController::TestCase

  def setup
    @goal = goals(:goal)
  end

  # test "should redirect create when not logged in" do
  #   assert_no_difference 'Goal.count' do
  #     post goals_path, params: { goal: { name: "New Home", description: "Saving up to buy a bigger home for the family.", amount: 150000 } }
  #   end
  #   assert_redirected_to login_url
  # end
  #
  # test "should redirect destroy when not logged in" do
  #   assert_no_difference 'Goal.count' do
  #     delete goal_path(@goal)
  #   end
  #   assert_redirected_to login_url
  # end

end
