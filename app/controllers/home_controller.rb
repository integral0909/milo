class HomeController < ApplicationController
  include ActionView::Helpers::NumberHelper

  BASE_URL = "http://milosavings.com?referral="
  before_action :authenticate_user!
  before_action :set_user
  before_action :get_referral_rank, only: :index

  def index

    @referral_link = Bitly.client.shorten(BASE_URL + current_user.id.to_s).short_url
    @goal = current_user.goals.build

    @transactions = PlaidHelper.current_week_transactions(@user, @checking)

    # Redirect users to proper sign up page if not complete
    if (@user.invited && !@user.is_verified)
      redirect_to signup_phone_path
    end
    @account_balance = number_to_currency((@user.account_balance / 100).round(2), unit:"") if @user.account_balance
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
    # If the user has no referrals, set the rank as last AKA the total count of Users
    @referral_rank = @referrals.keys.index(@user.id.to_s) ? @referrals.keys.index(@user.id.to_s) + 1 : User.all.count
    # show the amount of referrals the user has based on their user id as the hash field or 0 if none present
    @referral_count = @referrals[@user.id.to_s] ? @referrals[@user.id.to_s] : 0
  end

end
