class CheckingsController < ApplicationController

  def new
    @checking = Checking.new
    @accounts = Account.where(user_id: current_user.id, acct_subtype: "checking")

    render layout: "signup"
  end

  def create
    @checking = Checking.new(checking_params)

    respond_to do |format|
      if @checking.save

        # Upgrade user to utilizing Plaid Connect and save the transaction info for the checking account
        connect_user = Argyle.plaid_client.set_user(@user.plaid_access_token, ['connect'])
        Transaction.create_transactions(connect_user.transactions, @checking.plaid_acct_id, @user.id)

        Dwolla.connect_funding_source(@user)
        # TODO:send email about connecting the funding source

        format.html { redirect_to signup_on_demand_path, notice: 'Checking was successfully created.' }
        format.json { render :show, status: :created, location: @checking }
      else
        format.html { render :new }
        format.json { render json: @checking.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def checking_params
    params.require(:checking).permit(:user_id, :plaid_acct_id)
  end

end
