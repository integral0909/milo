# == Schema Information
#
# Table name: accounts
#
#  id                               :integer          not null, primary key
#  name                             :string
#  description                      :text
#  amount                           :integer
#  user_id                          :integer
#  created_at                       :date
#  updated_at                       :date
#  active                           :boolean
#  completed                        :boolean
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
  # FIRST-GOAL -----------------------------------
  # ----------------------------------------------
  # Set the first goal on user creation (First $50)
  def self.first_goal(user_id)
    user = User.find_by_id(user_id)
    Goal.create(name: "Get Your Account to $50",
                description: "Kickstart your savings by shifting your first $50 into your account.",
                amount: 50,
                user_id: user_id,
                active: true,
                completed: false)
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
