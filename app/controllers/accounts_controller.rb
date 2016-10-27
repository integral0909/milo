class AccountsController < ApplicationController

  def index
    render layout: "signup"
  end

  def remove
    @accounts = Account.where(user_id: current_user.id)
    @accounts.destroy_all
    @checking = Checking.where(user_id: current_user.id)
    @checking.destroy_all
  end

end
