require 'resque'

class DwollaQuickSaveJob
  @queue = :dwolla_queue

  def self.perform(user_id, amount)
    user = User.find(user_id)

    begin
      current_date = Date.today

      transfer_request = {
        :_links => {
          :source => {
            :href => user.dwolla_funding_source
          },
          :destination => {
            :href => "https://api-uat.dwolla.com/funding-sources/#{ENV["DWOLLA_FUNDING_SOURCE_FBO"]}"
          }
        },
        :amount => {
          :currency => "USD",
          :value => amount
        },
        :metadata => {
          :customerId => user.id,
          :transferType => ENV['DWOLLA_QUICK_SAVE']
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
      Transfer.create_transfers(user,"", current_transfer_url, current_transfer_status, amount, "", "deposit", current_date, false)

    rescue => e
      SupportMailer.basic_error(e).deliver_now
    end
  end
end
