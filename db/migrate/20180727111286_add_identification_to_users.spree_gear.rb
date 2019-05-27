# This migration comes from spree_gear (originally 20170225224229)
class AddIdentificationToUsers < ActiveRecord::Migration[5.1]
  def change
    add_attachment :spree_users, :identification
  end
end
