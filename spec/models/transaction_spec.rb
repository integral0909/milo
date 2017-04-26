# == Schema Information
#
# Table name: transactions
#
#  plaid_trans_id      :string           primary key
#  account_id          :string
#  amount              :float
#  trans_name          :string
#  plaid_cat_id        :integer
#  plaid_cat_type      :string
#  date                :date
#  vendor_address      :string
#  vendor_city         :string
#  vendor_state        :string
#  vendor_zip          :string
#  vendor_lat          :float
#  vendor_lon          :float
#  pending             :boolean
#  pending_transaction :string
#  name_score          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  new_amount          :float
#  roundup             :float
#  user_id             :integer
#

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
