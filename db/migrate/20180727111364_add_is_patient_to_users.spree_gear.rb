# This migration comes from spree_gear (originally 20180213133346)
class AddIsPatientToUsers < ActiveRecord::Migration[5.0]
  def up
    add_column :spree_users, :patient, :boolean, index: true
    add_column :spree_users, :admin, :boolean, index: true
    add_column :spree_users, :sales_rep, :boolean, index: true

    Spree::User.all.each do |user|
      user.update patient: user.has_spree_role?("patient"),
                  admin: user.has_spree_role?("admin"),
                  sales_rep: user.has_spree_role?("sales_rep")

    end
  end

  def down
    remove_column :spree_users, :patient, :boolean, index: true
    remove_column :spree_users, :admin, :boolean, index: true
    remove_column :spree_users, :sales_rep, :boolean, index: true
  end
end
