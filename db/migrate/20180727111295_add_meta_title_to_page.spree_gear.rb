# This migration comes from spree_gear (originally 20170225225736)
# This migration comes from spree_static_content (originally 20110717103112)
class AddMetaTitleToPage < ActiveRecord::Migration[5.1]
  def self.up
    add_column :spree_pages, :meta_title, :string
  end

  def self.down
    remove_column :spree_pages, :meta_title
  end
end
