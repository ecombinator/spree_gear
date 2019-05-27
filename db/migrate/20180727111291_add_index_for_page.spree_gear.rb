# This migration comes from spree_gear (originally 20170225225732)
# This migration comes from spree_static_content (originally 20090829000527)
class AddIndexForPage < ActiveRecord::Migration[5.1]
  def self.up
    add_index(:spree_pages, :slug)
  end

  def self.down
    remove_index(:spree_pages, :slug)
  end
end
