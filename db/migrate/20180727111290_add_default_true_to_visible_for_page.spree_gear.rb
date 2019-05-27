# This migration comes from spree_gear (originally 20170225225731)
# This migration comes from spree_static_content (originally 20090814142845)
class AddDefaultTrueToVisibleForPage < ActiveRecord::Migration[5.1]
  def self.up
    change_column :spree_pages, :visible, :boolean, default: true
  end

  def self.down
  end
end
