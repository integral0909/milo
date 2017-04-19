require 'resque'

class AddDwollaUserJob
  @queue = :dwolla_queue

  def self.perform(user_id)
    begin
      user = User.find(user_id)
      # We don't save name in 2 seperate fields so append -Shift to the name
      # TODO: add :ip_address => to customer creation with request.remote_ip
      request_body = {
        :firstName => user.name,
        :lastName => '-Shift',
        :email => user.email
      }
      @dwolla_app_token = Dwolla.set_dwolla_token
      dwolla_customer_url = @dwolla_app_token.post "customers", request_body
      # Add dwolla customer URL to the user
      user = User.find(user.id)
      user.dwolla_id = dwolla_customer_url.headers[:location]
      user.save!

      # Connnect new user with the funding source
      Dwolla.connect_funding_source(user)
    rescue => e
      SupportMailer.add_dwolla_user_failed(user, e).deliver_now
      return
    end
  end
end
