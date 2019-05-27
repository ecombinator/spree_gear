# This migration comes from spree_gear (originally 20170225225735)
# This migration comes from spree_static_content (originally 20100323085528)
class AddShowInSidebarOptionToPages < ActiveRecord::Migration[5.1]
  def self.up
    add_column :spree_pages, :show_in_sidebar, :boolean, default: false, null: false
  end

  def self.down
    remove_column :spree_pages, :show_in_sidebar
  end
end
