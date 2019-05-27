class AddRecipientOptionsToMailings < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_mailings, :deliver_to_users, :boolean, default: false
    add_column :spree_mailings, :deliver_to_non_users, :boolean, default: false
  end
end
