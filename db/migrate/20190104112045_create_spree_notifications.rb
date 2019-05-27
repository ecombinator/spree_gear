class CreateSpreeNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_notifications do |t|
      t.integer :user_id, index: true
      t.references :notifiable, polymorphic: true, index: true
      t.string :mailer_action, index: true
      t.boolean :auto_send, default: false
    end
  end
end
