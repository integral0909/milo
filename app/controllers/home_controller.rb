class HomeController < ApplicationController
  BASE_URL = "http://milosavings.com/users/sign_up?referral="
  before_action :authenticate_user!
  before_action :set_user
  before_action :get_referral_rank, only: :index

  def index
    # Find all accounts associated with the user
    @accounts = Account.where(user_id: @user.id)
    # Find the checking account associated with the user
    @checking = Checking.find_by(user_id: @user.id)
    # If, checking account exists get the transactions for that account
    if @checking
      @transactions = @user.transactions.where(account_id: @checking.plaid_acct_id)
    end
    @referral_link = Bitly.client.shorten(BASE_URL + current_user.id.to_s).short_url
  end

  private

  def get_referral_rank
    # @referral_rank = 1
    all_referrals = User.all.pluck("referral_code")
    # convert all referrals to hash with user id as the key and the referrals count as the value
    @referrals = all_referrals.each_with_object(Hash.new(0)) { |code,counts| counts[code] += 1 if !code.blank? }
    # use a sort + reverse to have the most referrals be at the front of the hash.
    @referrals = Hash[@referrals.sort_by(&:last).reverse]
    # find the current rank of the current user by refer. Convert to use just keys so we can find the index of the user
    @referral_rank = @referrals.keys.index(@user.id.to_s) + 1 if @referrals.keys.index(@user.id.to_s)
    # show the amount of referrals the user has based on their user id as the hash field
    @referral_count = @referrals[@user.id.to_s] if @referrals[@user.id.to_s]



  end

  def set_user
    @user = User.find(current_user.id)
  end

end
