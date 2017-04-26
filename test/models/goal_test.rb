# == Schema Information
#
# Table name: goals
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  amount      :decimal(, )
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  active      :boolean
#  completed   :boolean
#  gtype       :string
#  percentage  :decimal(, )
#  balance     :decimal(, )
#  preset      :boolean
#

require 'test_helper'

class GoalTest < ActiveSupport::TestCase

  def setup
    @user = users(:orville)
    @goal = @user.goals.build(name: "New Home", description: "Saving up to buy a bigger home for the family.", amount: 150000)
  end

  test "should be valid" do
    assert @goal.valid?
  end

  test "user id should be present" do
    @goal.user_id = nil
    assert_not @goal.valid?
  end

  test "name should be present" do
    @goal.content = " "
    assert_not @goal.valid?
  end

  test "amount should be present" do
    @goal.amount = " "
    assert_not @goal.valid?
  end

end
