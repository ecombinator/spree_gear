# This migration comes from spree_gear (originally 20170225225739)
# This migration comes from spree_static_content (originally 20160217113416)
class RemoveShowInFooterFromSpreePages < ActiveRecord::Migration[5.1]
  def self.up
    remove_column :spree_pages, :show_in_footer
  end

  def self.down
    add_column :spree_pages, :show_in_footer, :boolean, default: false, null: false
  end
end
