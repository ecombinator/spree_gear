# This migration comes from spree_gear (originally 20170518041839)
# This migration comes from spree_admin_roles_and_access (originally 20170508082722)
class AddDisplayBooleanToPermissionSets < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_permission_sets, :display_permission, :boolean, default: false
  end
end
