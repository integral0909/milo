# == Schema Information
#
# Table name: goals
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  amount      :integer
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  active      :boolean
#  completed   :boolean
#  type        :string
#  percentage  :decimal(, )
#  balance     :decimal(, )
#  preset      :boolean
#

require 'rails_helper'

RSpec.describe Goal, type: :model do

  it "adds checking with user and plaid account" do
    @user = User.create(email: 'biz_owner4@gmail.com', name:'test', zip: '90210', password: 'P@assw0rd')
    @goal = Goal.create(name: "test goal", amount: 200, user_id: @user.id)

    Goal.mark_as_completed(@goal)
    expect(@goal.completed).to eq(true)
    expect(@goal.active).to eq(false)
  end
end
