require 'resque'

class DwollaSendFundsToUserJob
  @queue = :dwolla_queue

  def self.perform(user_id, requested_amount)
    user = User.find(user_id)
    begin
      current_date = Date.today

      transfer_request = {
        :_links => {
          :source => {
            :href => "https://api-sandbox.dwolla.com/funding-sources/#{ENV["DWOLLA_FUNDING_SOURCE_FBO"]}"
          },
          :destination => {
            :href => user.dwolla_id
          }
        },
        :amount => {
          :currency => "USD",
          :value => requested_amount
        },
        :metadata => {
          :customerId => user.id,
          :transferType => ENV['DWOLLA_WITHDRAW']
        }
      }
      @dwolla_app_token = Dwolla.set_dwolla_token
      # Using DwollaV2 - https://github.com/Dwolla/dwolla-v2-ruby (Recommended)
      transfer = @dwolla_app_token.post "transfers", transfer_request

      current_transfer_url = transfer.headers[:location]

      # Get the status of the current transfer
      @dwolla_app_token = Dwolla.set_dwolla_token
      transfer_status = @dwolla_app_token.get current_transfer_url
      current_transfer_status = transfer_status['status']

      # Save the withdraw as a transfer. Params are the user, transfer_url, transfer_status, roundup_amount, roundup_count, transfer_type, current_date, tech_fee_charged
      Transfer.create_transfers(user,"", current_transfer_url, current_transfer_status, requested_amount, "", "withdraw", current_date, false)

      User.decrease_account_balance(user, requested_amount)

      # send email to user about funds being transfered to their account.
      funding_account  = Checking.find_by_user_id(user.id)

      BankingMailer.withdraw_start(user, requested_amount, funding_account).deliver_now

    rescue => e
      # TODO: this needs to happen when we get the customer_transfer_failed webhook response

      # send email to dev team about failed transfer to user
      SupportMailer.user_withdraw_failed(user, requested_amount, e).deliver_now
    end
  end
end
