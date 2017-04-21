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

# ================================================
# RUBY->MODEL->GOAL ==============================
# ================================================
class Goal < ActiveRecord::Base

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  belongs_to :user

  # ----------------------------------------------
  # VALIDATIONS ----------------------------------
  # ----------------------------------------------
  validates :name, presence: true
  validates :amount, presence: true
  validates :user_id, presence: true

  # ----------------------------------------------
  # CALLBACKS ------------------------------------
  # ----------------------------------------------
  after_create :set_goal_split

  # ----------------------------------------------
  # FIRST-GOAL -----------------------------------
  # ----------------------------------------------
  # Set the first goal on user creation (First $50)
  def first_goal(user_id)
    user = User.find_by_id(user_id)
    Goal.create(name: "Get Your Account to $50",
                description: "Kickstart your savings by shifting your first $50 into your account.",
                amount: 50,
                user_id: user_id,
                active: true,
                completed: false,
                preset: true)
  end

  # ----------------------------------------------
  # FIRST-GOAL-PROGRESS --------------------------
  # ----------------------------------------------
  # Track the progress of the first goal
  def first_goal_progress(user_id)
    user = User.find_by_id(user_id)
    goal_percentage = (user.account_balance * 100 / self.amount) / 100.00
  end

  # ----------------------------------------------
  # GOAL-PROGRESS --------------------------------
  # ----------------------------------------------
  # Track the progress of the first goal
  def goal_progress
    goal_percentage = (self.balance.to_i * 100 / self.amount) / 100.00
  end

  # ----------------------------------------------
  # SET-GOAL-SPLIT -------------------------------
  # ----------------------------------------------
  # When multiple goals, after create automatically
  # set the contribution split
  def set_goal_split
    user = User.find(self.user_id)
    total_goals = user.goals.where(preset: nil).all
    puts "========================================"
    puts total_goals.size
    puts "========================================"
    split = (100 / total_goals.size)
    puts "========================================"
    puts split
    puts "========================================"
    total_goals.each do |g|
      g.update_attributes(percentage: split)
    end
  end

  # ----------------------------------------------
  # MARK-AS-COMPLETED ----------------------------
  # ----------------------------------------------
  # Change the goal to completed and inactive once the user's balance reaches the goal amount.
  def self.mark_as_completed(goal)
    goal.completed = true
    goal.active = false
    goal.save!
  end
end
