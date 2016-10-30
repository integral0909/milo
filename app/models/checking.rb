# == Schema Information
#
# Table name: checkings
#
#  id                               :integer          not null, primary key
#  user_id                          :integer
#  plaid_acct_id                    :string
#

# ================================================
# RUBY->MODEL->CHECKING ==========================
# ================================================
class Checking < ActiveRecord::Base

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  belongs_to :user

  has_one :account

end
