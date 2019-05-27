class AddStatusToMailings < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_mailings, :submitted_emails_count, :integer, default: 0
    add_column :spree_mailings, :failed_emails_count, :integer, default: 0
    add_column :spree_mailings, :sent_emails_count, :integer, default: 0
    add_attachment :spree_mailings, :csv
  end
end
