# This migration comes from spree_gear (originally 20170518041841)
# This migration comes from spree_admin_roles_and_access (originally 20170509082144)
class RemoveColumnBooleanFromPermissions < ActiveRecord::Migration[5.0]
  def change
    remove_column :spree_permissions, :boolean, :boolean, default: true
  end
end
