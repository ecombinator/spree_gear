# This migration comes from spree_gear (originally 20170225225734)
# This migration comes from spree_static_content (originally 20100204105222)
class AddLayoutToPages < ActiveRecord::Migration[5.1]
  def self.up
    add_column :spree_pages, :layout, :string
  end

  def self.down
    remove_column :spree_pages, :layout
  end
end
