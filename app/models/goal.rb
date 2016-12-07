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
  # MARK-AS-COMPLETED ----------------------------
  # Change the goal to completed and inactive once the user's balance reaches the goal amount.
  # ----------------------------------------------
  def self.mark_as_completed(goal)
    goal.completed = true
    goal.active = false
    goal.save!
  end
end
