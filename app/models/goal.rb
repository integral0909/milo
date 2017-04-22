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
    goal_percentage = (user.account_balance / self.amount.to_i)
  end

  # ----------------------------------------------
  # GOAL-PROGRESS --------------------------------
  # ----------------------------------------------
  # Track the progress of goals
  def goal_progress
    goal_percentage = (self.balance.to_i * 100 / self.amount.to_i)
  end

  # ----------------------------------------------
  # SET-GOAL-SPLIT -------------------------------
  # ----------------------------------------------
  # When multiple goals, after create automatically
  # set the contribution split
  def set_goal_split
    user = User.find(self.user_id)
    total_goals = user.goals.where(preset: nil).all
    split = (100 / total_goals.size)
    total_goals.each do |g|
      g.update_attributes(percentage: split)
    end
  end

  # ----------------------------------------------
  # ADD-SPLIT-CONTRIBUTION -----------------------
  # ----------------------------------------------
  # Add amount to goals based on split for transfers
  def add_split_contribution(amount)
    contribution = amount * (self.percentage * 0.01)
    !self.balance.nil? ? self.balance += contribution : self.balance = contribution
    self.save!
  end
end
