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

  # ----------------------------------------------
  # ACCOUNTS-CREATE ------------------------------
  # ----------------------------------------------
  def self.create_accounts(plaid_user_accounts, public_token, user_id)
    plaid_user_accounts.each do |acct|
      account = Account.find_by(plaid_acct_id: acct.id)
      # IF, account exists update
      if account
        account.update(
          account_name: acct.meta["name"],
          account_number: acct.meta["number"],
          available_balance: acct.available_balance,
          current_balance: acct.current_balance,
          institution_type: acct.institution,
          name: acct.name,
          numbers: acct.numbers,
          bank_account_number: acct.numbers[:account],
          bank_routing_number: acct.numbers[:routing],
          acct_subtype: acct.subtype,
          acct_type: acct.type,
          user_id: user_id,
          public_token_id: public_token.id
          )
      # ELSE, create account
      else
        Account.create(
          plaid_acct_id: acct.id,
          account_name: acct.meta["name"],
          account_number: acct.meta["number"],
          available_balance: acct.available_balance,
          current_balance: acct.current_balance,
          institution_type: acct.institution,
          name: acct.name,
          numbers: acct.numbers,
          bank_account_number: acct.numbers[:account],
          bank_routing_number: acct.numbers[:routing],
          acct_subtype: acct.subtype,
          acct_type: acct.type,
          user_id: user_id,
          public_token_id: public_token.id
          )
      end
    end
  end

  # ----------------------------------------------
  # ACCOUNTS-UPDATE ------------------------------
  # ----------------------------------------------
  def self.update_accounts(user_id, public_token, milo_id)
    user_accounts = Account.where(user_id: user_id).all
    user_accounts.each do |acct|
      account = Account.find_by(plaid_acct_id: acct._id)
      if account
        account.update(
          available_balance: acct.balance.available,
          current_balance: acct.balance.current,
          name: acct.meta.name
          )
      else
        account = Account.create(
          plaid_acct_id: acct._id,
          account_name: acct.meta.name,
          account_number: acct.meta.number,
          available_balance: acct.balance.available,
          current_balance: acct.balance.current,
          institution_type: acct.institution_type,
          name: acct.meta.name,
          numbers: acct.meta.number,
          bank_account_number: acct.numbers['account'],
          bank_routing_number: acct.numbers['routing'],
          acct_subtype: acct.subtype,
          acct_type: acct.type,
          user_id: milo_id,
          public_token_id: public_token.id
          )
      end
    end
  end
end
