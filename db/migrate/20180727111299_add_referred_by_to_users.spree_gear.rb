# This migration comes from spree_gear (originally 20170324013104)
class AddReferredByToUsers < ActiveRecord::Migration[5.1]
  def change
    add_reference :spree_users, :referred_by, references: :spree_users
    add_foreign_key :spree_users, :spree_users, column: :referred_by_id
  end
end
