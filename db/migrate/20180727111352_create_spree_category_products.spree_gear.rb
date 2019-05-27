# This migration comes from spree_gear (originally 20171229134614)
class CreateSpreeCategoryProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_category_products do |t|
      t.integer :product_id
      t.integer :home_category_id
      t.integer :order

      t.timestamps
    end

    add_index :spree_category_products, :product_id
    add_index :spree_category_products, :home_category_id
    add_index :spree_category_products, :order
  end
end
