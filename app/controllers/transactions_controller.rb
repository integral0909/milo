class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :update, :edit]

  def index
    @user = User.find(current_user.id)
    @transactions = @user.transactions
  end

  def show
  end

  private

  def set_transactions
    @transaction = Transaction.find_by(params[:plaid_trans_id])
  end

  def transaciton_params
    params.require(:plaid_trans_id).permit(:plaid_trans_id)
  end
end
