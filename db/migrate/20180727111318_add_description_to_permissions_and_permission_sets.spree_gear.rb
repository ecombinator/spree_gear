# This migration comes from spree_gear (originally 20170518041838)
# This migration comes from spree_admin_roles_and_access (originally 20170508082615)
class AddDescriptionToPermissionsAndPermissionSets < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_permissions, :description, :string, default: ''
    add_column :spree_permission_sets, :description, :string, default: ''
  end
end
