# This migration comes from spree_gear (originally 20170405172238)
class AddNameTitleToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_users, :name, :string
    add_column :spree_users, :title, :string
  end
end
