class CreateWebhookEvents < ActiveRecord::Migration
  def change
    create_table :webhook_events do |t|
      t.string :service
      t.string :response_id
      t.string :topic
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
