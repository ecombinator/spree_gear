# This migration comes from spree_gear (originally 20170518041833)
# This migration comes from spree_admin_roles_and_access (originally 20130709104945)
class CreateSpreeRolesPermissions < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_roles_permissions, id: false do |t|
      t.integer :role_id, null: false
      t.integer :permission_id, null: false
    end

    add_index(:spree_roles_permissions, :role_id)
    add_index(:spree_roles_permissions, :permission_id)
  end
end
