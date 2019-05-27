# This migration comes from spree_gear (originally 20170223012160)
# This migration comes from spree_auth (originally 20101214150824)
class ConvertUserRememberField < ActiveRecord::Migration[5.1]
  def up
    remove_column :spree_users, :remember_created_at
    add_column :spree_users, :remember_created_at, :datetime
  end

  def down
    remove_column :spree_users, :remember_created_at
    add_column :spree_users, :remember_created_at, :string
  end
end
