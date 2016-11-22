# ================================================
# RUBY->CONTROLLER->HOME-CONTROLLER ==============
# ================================================
class HomeController < ApplicationController

  # ----------------------------------------------
  # INCLUDES -------------------------------------
  # ----------------------------------------------
  include ActionView::Helpers::NumberHelper

  # ----------------------------------------------
  # VARIABLES ------------------------------------
  # ----------------------------------------------
  BASE_URL = "http://milosavings.com?referral="

  # ----------------------------------------------
  # FILTERS --------------------------------------
  # ----------------------------------------------
  before_action :authenticate_user!
  before_action :set_user
  before_action :get_referral_rank, only: :index

  # ==============================================
  # ACTIONS ======================================
  # ==============================================

  # ----------------------------------------------
  # INDEX ----------------------------------------
  # ----------------------------------------------
  def index
    # Users account balance converted to dollars
    @account_balance = number_to_currency(@user.account_balance / 100.00, unit:"") if @user.account_balance

    # Users unique referral link
    @referral_link = Bitly.client.shorten(BASE_URL + current_user.id.to_s).short_url

    @goal = current_user.goals.build

    if !@user.account_balance.nil?
      @goal_percentage = (@user.account_balance * 100 / @user.goals.first.amount) / 100.00
    else
      @goal_percentage = 0
    end

    # Pull in the users transactions from the current week. The week starts on Sunday
    @transactions = PlaidHelper.current_week_transactions(@user, @checking)
    @total_pending = 0

    @transactions.each{ |tr| @total_pending += tr[:roundup]  } if @transactions

    # Show the latest 3 transfers
    @transfers = Transfer.where(user_id: @user.id).order('date ASC').limit(3)

    # Redirect users to proper sign up page if not complete
    if (@user.invited && !@user.is_verified)
      redirect_to signup_phone_path
    end
  end

  # ----------------------------------------------
  # HISTORY --------------------------------------
  # ----------------------------------------------
  # Page to see round up transfer history
  def history
    @transfers = Transfer.where(user_id: @user.id)
  end

  # ----------------------------------------------
  # ROUNDUPS ------------------------------------
  # ----------------------------------------------
  def roundups
    # Users account balance converted to dollars
    @account_balance = number_to_currency(@user.account_balance / 100.00, unit:"") if @user.account_balance
    # Transfers
    @transfers = Transfer.where(user_id: @user.id).all
    @transfer_total = @transfers.size
    all_transfer_amounts = @transfers.map {|tr| tr.roundup_amount.to_f }
    @transfer_avg = number_to_currency(all_transfer_amounts.inject{ |sum, el| sum + el }.to_f / all_transfer_amounts.size)
    # Transactions
    @transactions.each{ |tr| @total_pending += tr[:roundup]  } if @transactions
    # Round Ups
    @trans = Transaction.where(user_id: @user.id).all
    @roundup_total = @trans.size
    @roundup_avg = number_to_currency(@trans.average(:roundup))
    # Spent
    @spent_avg = number_to_currency(@trans.average(:amount))
  end

  # ==============================================
  # PRIVATE ======================================
  # ==============================================
  private

  # ----------------------------------------------
  # REFERRAL-RANK --------------------------------
  # ----------------------------------------------
  def get_referral_rank
    # @referral_rank = 1
    all_referrals = User.all.pluck("referral_code")
    # convert all referrals to hash with user id as the key and the referrals count as the value
    @referrals = all_referrals.each_with_object(Hash.new(0)) { |code,counts| counts[code] += 1 if !code.blank? }
    # use a sort + reverse to have the most referrals be at the front of the hash.
    @referrals = Hash[@referrals.sort_by(&:last).reverse]
    # find the current rank of the current user by refer. Convert to use just keys so we can find the index of the user
    # If the user has no referrals, set the rank as last AKA the total count of Users
    @referral_rank = @referrals.keys.index(@user.id.to_s) ? @referrals.keys.index(@user.id.to_s) + 1 : User.all.count
    # show the amount of referrals the user has based on their user id as the hash field or 0 if none present
    @referral_count = @referrals[@user.id.to_s] ? @referrals[@user.id.to_s] : 0
  end

end
