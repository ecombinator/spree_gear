# This migration comes from spree_gear (originally 20170518041836)
# This migration comes from spree_admin_roles_and_access (originally 20170503091013)
class CreateSpreeRolesPermissionSets < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_roles_permission_sets do |t|
      t.references :role, index: true, foreign_key: { to_table: :spree_roles }
      t.references :permission_set, index: true, foreign_key: { to_table: :spree_permission_sets }
    end
  end
end
