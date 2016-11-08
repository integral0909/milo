# == Schema Information
#
# Table name: public_tokens
#
#  id                               :integer          not null, primary key
#  token                            :string
#  user_id                          :string
#

# ================================================
# RUBY->MODEL->PUBLIC-TOKEN ======================
# ================================================
class PublicToken < ActiveRecord::Base

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  belongs_to :user
  
  has_many :accounts

end
