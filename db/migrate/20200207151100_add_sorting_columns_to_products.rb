class AddSortingColumnsToProducts < ActiveRecord::Migration[5.2]
  def up
    add_column :spree_products, :deepest_taxon_id, :integer
    add_index :spree_products, :main_category_name
    add_index :spree_products, :deepest_taxon_id
    Spree::Product.all.each &:update_deepest_taxon_id
  end

  def down
    remove_column :spree_products, :deepest_taxon_id
    remove_index :spree_products, :main_category_name
  end
end
