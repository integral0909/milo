class AddFailedVerificationAttemptToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :failed_verification_attempt, :integer
  end
end
