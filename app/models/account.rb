# == Schema Information
#
# Table name: accounts
#
#  plaid_acct_id                    :string          primary key
#  account_name                     :string
#  account_number                   :string
#  available_balance                :float
#  current_balance                  :float
#  institution_type                 :string
#  name                             :string
#  numbers                          :string
#  acct_subtype                     :string
#  acct_type                        :string
#  user_id                          :integer
#  public_token_id                  :integer
#  checking_id                      :integer
#  bank_account_number              :sting
#  bank_routing_number              :string
#

# ================================================
# RUBY->MODEL->ACCOUNT ===========================
# ================================================
class Account < ActiveRecord::Base

  # ----------------------------------------------
  # PRIMARY-KEY ----------------------------------
  # ----------------------------------------------
  self.primary_key = 'plaid_acct_id'

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  belongs_to :user
  belongs_to :public_token
  belongs_to :checking

  has_many :transactions

end
