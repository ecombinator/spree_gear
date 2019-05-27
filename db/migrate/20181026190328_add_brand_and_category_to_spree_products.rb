class AddBrandAndCategoryToSpreeProducts < ActiveRecord::Migration[5.2]
  def up
    add_column :spree_products, :brand_name, :string, index: true
    add_column :spree_products, :main_category_name, :string, index: true

    Spree::Product.all.each &:update_brand_and_main_category
  end

  def down
    remove_column :spree_products, :brand_name
    remove_column :spree_products, :main_category_name
  end
end
