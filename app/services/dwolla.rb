require 'dwolla_swagger'

# All Dwolla functionality will be held here
class Dwolla
    def create_account(user)
      request_body = {
        :firstName => 'Milo',
        :lastName => user.name,
        :email => user.email,
      }

      # Using DwollaSwagger - https://github.com/Dwolla/dwolla-swagger-ruby
      dwolla_customer_url = DwollaSwagger::CustomersApi.create(:body => request_body)

      # TODO: add dwolla customer URL to the user
      user = User.find(user.id)
      user.dwolla_url = dwolla_customer_url
      user.save!

    end
end
