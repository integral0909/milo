class Transaction < ActiveRecord::Base

  self.primary_key = 'plaid_trans_id'

  belongs_to :account
  delegate :user, :to => :account

  before_save :round_transaction, :roundup

  def self.create_accounts(plaid_user_accounts, public_token, user_id)
    plaid_user_accounts.each do |acct|
      account = Account.find_by(plaid_acct_id: acct.id)
      if account
        account.update(
          account_name: acct.meta["name"],
          account_number: acct.meta["number"],
          available_balance: acct.available_balance,
          current_balance: acct.current_balance,
          institution_type: acct.institution_type,
          name: acct.name,
          numbers: acct.numbers,
          bank_account_number: acct.numbers['account'],
          bank_routing_number: acct.numbers['routing'],
          acct_subtype: acct.subtype,
          acct_type: acct.type,
          user_id: user_id,
          public_token_id: public_token.id
          )
      else
        Account.create(
          plaid_acct_id: acct.id,
          account_name: acct.meta["name"],
          account_number: acct.meta["number"],
          available_balance: acct.available_balance,
          current_balance: acct.current_balance,
          institution_type: acct.institution_type,
          name: acct.name,
          numbers: acct.numbers,
          bank_account_number: acct.numbers['account'],
          bank_routing_number: acct.numbers['routing'],
          acct_subtype: acct.subtype,
          acct_type: acct.type,
          user_id: user_id,
          public_token_id: public_token.id
          )
      end
    end
  end

  def self.create_transactions(plaid_user_transactions, plaid_checking_id, user_id)
    current_date = Date.today
    last_week_date = current_date - 1.week

    plaid_user_transactions.each do |transaction|
      # only save positive transactions and that are within a week old

      # TODO :: DWOLLA TESTING
      #if (transaction.amount > 0)
      if (transaction.amount > 0) && (transaction.date.to_date > last_week_date)
        newtrans = Transaction.find_by(plaid_trans_id: transaction.id)

        vendor_address = transaction.location["address"]
        vendor_city = transaction.location["city"]
        vendor_state = transaction.location["state"]
        vendor_zip = transaction.location["zip"]

        if !transaction.location["coordinates"].nil?
          vendor_lat = transaction.location["coordinates"]["lat"]
          vendor_lon = transaction.location["coordinates"]["lon"]
        else
          vendor_lat = nil
          vendor_lon = nil
        end

        if newtrans
          newtrans.update(
            plaid_trans_id: transaction.id,
            account_id: transaction.account,
            amount: transaction.amount,
            trans_name: transaction.name,
            plaid_cat_id: transaction.category_id.to_i,
            plaid_cat_type: transaction.type["primary"],
            date: transaction.date.to_date,

            vendor_address: vendor_address,
            vendor_city: vendor_city,
            vendor_state: vendor_state,
            vendor_zip: vendor_zip,
            vendor_lat: vendor_lat,
            vendor_lon: vendor_lon,

            pending: transaction.pending,
            pending_transaction: transaction.pending_transaction,
            name_score: transaction.score["name"],
            )
        else
          if transaction.account == plaid_checking_id
            newtrans = Transaction.create(
              plaid_trans_id: transaction.id,
              account_id: transaction.account,
              amount: transaction.amount,
              trans_name: transaction.name,
              plaid_cat_id: transaction.category_id.to_i,
              plaid_cat_type: transaction.type["primary"],
              date: transaction.date.to_date,

              vendor_address: vendor_address,
              vendor_city: vendor_city,
              vendor_state: vendor_state,
              vendor_zip: vendor_zip,
              vendor_lat: vendor_lat,
              vendor_lon: vendor_lon,

              pending: transaction.pending,
              pending_transaction: transaction.pending_transaction,
              name_score: transaction.score["name"],
              user_id: user_id
              )
          end
        end
        if newtrans
          if newtrans.plaid_cat_id == 0 || newtrans.plaid_cat_id == nil
            #newtrans.category = Category.find_by(name: "Tag")
            newtrans.save
          else
            #newtrans.category = PlaidCategory.find_by(plaid_cat_id: newtrans.plaid_cat_id).category
            newtrans.save
          end
        end
      end
    end
  end

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
          account_name: acct.meta.name,
          account_number: acct.meta.number,
          available_balance: acct.balance.available,
          current_balance: acct.balance.current,
          institution_type: acct.institution_type,
          name: acct.meta.name,
          numbers: acct.meta.number,
          bank_account_number: acct.numbers['account'],
          bank_routing_number: acct.numbers['routing'],
          acct_subtype: acct.subtype,
          acct_type: acct.type,
          user_id: milo_id,
          public_token_id: public_token.id
          )

      end
    end
  end


  def self.update_transactions(user_transactions, user_id)

    user_transactions.each do |transaction|
      trans = Transaction.find_by(plaid_trans_id: transaction._id)
      vendor_lat = nil
      vendor_lon = nil
      if transaction.meta.location.coordinates
        vendor_lat = transaction.meta.location.coordinates.lat
        vendor_lon = transaction.meta.location.coordinates.lon
      end
      if trans == nil
        trans = Transaction.create(
          plaid_trans_id: transaction._id,
          account_id: transaction._account,
          amount: transaction.amount,
          trans_name: transaction.name,
          plaid_cat_id: transaction.category_id.to_i,
          plaid_cat_type: transaction.type.primary,
          date: transaction.date.to_date,

          vendor_address: transaction.meta.location.address,
          vendor_city: transaction.meta.location.city,
          vendor_state: transaction.meta.location.state,
          vendor_zip: transaction.meta.location.zip,
          vendor_lat: vendor_lat,
          vendor_lon: vendor_lon,

          pending: transaction.pending,
          pending_transaction: transaction.pending_transaction,
          name_score: transaction.score.name,
          user_id: user_id
          )
      end
    end
  end

  def round_transaction
    self.new_amount = self.amount.ceil
  end

  def roundup
    if self.new_amount > 0.00
      subtract = self.new_amount - self.amount
      if subtract == 0
        self.roundup = 1.00
      else
        self.roundup = subtract.round(2)
      end
    else
      self.roundup = 0.00
    end
  end

end
