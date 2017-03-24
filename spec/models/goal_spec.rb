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
