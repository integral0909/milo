require 'rails_helper'

RSpec.describe Transaction, type: :model do
  before(:each) do
    @user = User.create(email: 'biz_owner3@gmail.com', name:'test', zip: '90210', password: 'P@assw0rd', plaid_access_token: "test_wells")

    @checking = Checking.create( user_id: @user.id, plaid_acct_id: "nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy")

    connect_user = Plaid::User.load(:connect, @user.plaid_access_token)

    user_transactions = connect_user.transactions()

    @current_transactions = user_transactions.select{|a| (a.account_id == @checking.plaid_acct_id)}

  end

  it "adds checking with user and plaid account" do
    Transaction.create_transactions(@current_transactions, @checking.plaid_acct_id, @user.id)

    expect(Transaction.first.user_id).to eq(@user.id)
  end
end
