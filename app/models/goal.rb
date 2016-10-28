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
#

# ================================================
# RUBY->MODEL->GOAL ==============================
# ================================================
class Goal < ActiveRecord::Base

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  belongs_to :user
  
end
