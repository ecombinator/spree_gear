# This migration comes from spree_gear (originally 20170327070943)
class AddPhoneAndCompanyToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_users, :phone, :string
    add_column :spree_users, :company, :string
  end
end
