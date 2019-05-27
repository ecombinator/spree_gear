# This migration comes from spree_gear (originally 20170223012163)
# This migration comes from spree_auth (originally 20140904000425)
class AddDeletedAtToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_users, :deleted_at, :datetime
    add_index :spree_users, :deleted_at
  end
end
