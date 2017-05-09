module DwollaWebhooks
  def self.process_webhook_event(params)
    topic =  params['topic']

    case topic
    when 'customer_transfer_created'
      # send email about transfer start
    when 'customer_transfer_completed'

      transfer = ;;
      # send email about transfer completed, update users account balance at this point
    when 'customer_transfer_failed'
      # send failed transfer email to user
    when 'bank_transfer_created'

    when 'bank_transfer_completed'

    when 'bank_transfer_failed'
      # send failed transfer email to support
    end
  end
end
