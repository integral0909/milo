class Transfer < ActiveRecord::Base

  def self.create_transfers(user, transfer_url, transfer_status, roundup_ammount, roundup_count, transfer_type)
    # creat transfer object on roundup deposit
    Transfer.create(
      user_id: user.id,
      dwolla_url: transfer_url,
      status: transfer_status,
      roundup_ammount: roundup_ammount,
      roundup_count: roundup_count,
      transfer_type: transfer_type
    )
  end

end
