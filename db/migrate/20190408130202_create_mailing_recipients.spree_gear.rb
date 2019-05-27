class CreateMailingRecipients < ActiveRecord::Migration[5.2]
  def up
    enable_extension 'uuid-ossp'
    enable_extension 'pgcrypto'
    create_table :spree_mailing_recipients, id: :uuid do |t|
      t.string :email, null: false, index: true
      t.integer :spree_user_id, index: true
      t.boolean :opted_in, default: false
    end

    Spree::User.all.each do |user|
      Spree::MailingRecipient.where( email: user.email, spree_user_id: user.id ).first_or_create do |recipient|
        recipient.opted_in = true
        recipient.save!
      end
    end
  end
end


