class AccountsController < ApplicationController
  def index
    @user = User.find(current_user.id)
    @accounts = @user.accounts
  end
end
