# This migration comes from spree_gear (originally 20170518041835)
# This migration comes from spree_admin_roles_and_access (originally 20170503090436)
class CreateSpreePermissionSets < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_permission_sets do |t|
      t.string :name, null: false, unique: true

      t.timestamps
    end
  end
end
