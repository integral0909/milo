# == Schema Information
#
# Table name: accounts
#
#  plaid_acct_id               :string           primary key
#  account_name                :string
#  account_number              :string
#  available_balance           :float
#  current_balance             :float
#  institution_type            :string
#  name                        :string
#  numbers                     :string
#  acct_subtype                :string
#  acct_type                   :string
#  user_id                     :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  public_token_id             :integer
#  checking_id                 :integer
#  bank_account_number         :string
#  bank_routing_number         :string
#  failed_verification_attempt :integer
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

  validates :bank_routing_number, length: { is: 9 }, on: :update
  validates :bank_account_number, length: { minimum: 4 }, on: :update

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
          institution_type: acct.institution.to_s,
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
      elsif acct.subtype && acct.numbers && !acct.numbers.empty?  && acct.meta
        Account.create(
          plaid_acct_id: acct.id,
          account_name: acct.meta["name"],
          account_number: acct.meta["number"],
          available_balance: acct.available_balance,
          current_balance: acct.current_balance,
          institution_type: acct.institution.to_s,
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
  # LONG-TAIL-ACCOUNTS-CREATE --------------------
  # ----------------------------------------------
  def self.create_long_tail_account(plaid_user_accounts, public_token, user_id)
    plaid_user_accounts.each do |acct|
      account = Account.find_by(plaid_acct_id: acct.id)
      # IF, account exists update
      if account
        account.update(
          account_name: acct.meta["name"],
          account_number: acct.meta["number"],
          available_balance: acct.available_balance,
          current_balance: acct.current_balance,
          institution_type: acct.institution.to_s,
          name: acct.name,
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
          institution_type: acct.institution.to_s,
          name: acct.name,
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
          account_name: acct.meta["name"],
          account_number: acct.meta["number"],
          available_balance: acct.balance.available,
          current_balance: acct.balance.current,
          institution_type: acct.institution_type,
          name: acct.meta.name,
          numbers: acct.meta.number,
          bank_account_number: acct.numbers[:account],
          bank_routing_number: acct.numbers[:routing],
          acct_subtype: acct.subtype,
          acct_type: acct.type,
          user_id: milo_id,
          public_token_id: public_token.id
          )
      end
    end
  end

  # ----------------------------------------------
  # MICRO-DEPOSIT-VERIFICATION-FAILED ------------
  # Called when a user fails to enter the correct deposited amounts
  # ----------------------------------------------
  def self.micro_deposit_verification_failed(acct, user)
    # Add 1 to the user's failed verification attempts count.
    acct.failed_verification_attempt ? acct.failed_verification_attempt += 1 : acct.failed_verification_attempt = 1

    acct.save!
  end

  # ----------------------------------------------
  # REMOVE-ACCOUNTS ------------------------------
  # Remove all accounts, checking, and fields related to users accounts
  # ----------------------------------------------
  def self.remove_accounts(user)
    user = User.find(user.id)

    accounts = Account.where(user_id: user.id)
    accounts.destroy_all

    checking = Checking.where(user_id: user.id)
    checking.destroy_all

    Dwolla.remove_funding_source(user)

    user.on_demand = false
    user.long_tail = false
    user.save!
  end
end
