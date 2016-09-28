class Transfer < ActiveRecord::Base

  def self.create_transfer_on_roundup(current_transfer_url, current_transfer_status, user, roundup_ammount, roundup_count, type)
    # creat transfer object on roundup depoit
    Transfer.create(
      user_id: user.id,
      dwolla_url: current_transfer_url,
      status: current_transfer_status,
      roundup_count: roundup_count,
      roundup_ammount: roundup_ammount,
      type: type
    )
  end

end
