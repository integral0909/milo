# == Schema Information
#
# Table name: transactions
#
#  plaid_trans_id                   :integer          primary key
#  account_id                       :string
#  amount                           :float
#  trans_name                       :string
#  plaid_cat_id                     :integer
#  plaid_cat_type                   :string
#  date                             :date
#  vendor_address                   :string
#  vendor_city                      :string
#  vendor_state                     :string
#  vendor_zip                       :string
#  vendor_lat                       :float
#  vendor_lon                       :float
#  pending                          :boolean
#  pending_transaction              :string
#  name_score                       :integer
#  new_amount                       :float            scale: 2
#  roundup                          :float            scale: 2
#  user_id                          :integer
#

# ================================================
# RUBY->MODEL->TRANSACTION =======================
# ================================================
class Transaction < ActiveRecord::Base

  # ----------------------------------------------
  # PRIMARY-KEY ----------------------------------
  # ----------------------------------------------
  self.primary_key = 'plaid_trans_id'

  # ----------------------------------------------
  # RELATIONS ------------------------------------
  # ----------------------------------------------
  belongs_to :account

  delegate :user, :to => :account

  # ----------------------------------------------
  # CALLBACKS ------------------------------------
  # ----------------------------------------------
  before_save :round_transaction, :roundup

  # ----------------------------------------------
  # TRANSACTIONS-CREATE --------------------------
  # ----------------------------------------------
  def self.create_transactions(plaid_user_transactions, plaid_checking_id, user_id)
    current_date = Date.today
    last_week_date = current_date - 1.week

    plaid_user_transactions.each do |transaction|
      # only save positive transactions and that are within a week old

      # TODO :: TESTING
      if (transaction.amount > 0)
      # if (transaction.amount > 0) && (transaction.date.to_date > last_week_date)
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
        # IF, transactions exists update
        if newtrans
          newtrans.update(
            plaid_trans_id: transaction.id,
            account_id: transaction.account_id,
            amount: transaction.amount,
            trans_name: transaction.name,
            plaid_cat_id: transaction.category_id.to_i,
            plaid_cat_type: transaction.type[:primary].to_s,
            date: transaction.date.to_date,

            vendor_address: vendor_address,
            vendor_city: vendor_city,
            vendor_state: vendor_state,
            vendor_zip: vendor_zip,
            vendor_lat: vendor_lat,
            vendor_lon: vendor_lon,

            pending: transaction.pending,
            name_score: transaction.score[:name],
            )
        # ELSE, create transaction
        else
          if transaction.account_id == plaid_checking_id
            newtrans = Transaction.create(
              plaid_trans_id: transaction.id,
              account_id: transaction.account_id,
              amount: transaction.amount,
              trans_name: transaction.name,
              plaid_cat_id: transaction.category_id.to_i,
              plaid_cat_type: transaction.type[:primary].to_s,
              date: transaction.date.to_date,

              vendor_address: vendor_address,
              vendor_city: vendor_city,
              vendor_state: vendor_state,
              vendor_zip: vendor_zip,
              vendor_lat: vendor_lat,
              vendor_lon: vendor_lon,

              pending: transaction.pending,
              name_score: transaction.score[:name],
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

  # ----------------------------------------------
  # TRANSACTIONS-UPDATE --------------------------
  # ----------------------------------------------
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
          plaid_cat_type: transaction.type[:primary].to_s,
          date: transaction.date.to_date,

          vendor_address: transaction.meta.location.address,
          vendor_city: transaction.meta.location.city,
          vendor_state: transaction.meta.location.state,
          vendor_zip: transaction.meta.location.zip,
          vendor_lat: vendor_lat,
          vendor_lon: vendor_lon,

          pending: transaction.pending,
          name_score: transaction.score[:name],
          user_id: user_id
          )
      end
    end
  end

  # ----------------------------------------------
  # TRANSACTION-ROUNDUP --------------------------
  # ----------------------------------------------
  def round_transaction
    self.new_amount = self.amount.ceil
  end

  # ----------------------------------------------
  # ROUNDUP --------------------------------------
  # ----------------------------------------------
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
