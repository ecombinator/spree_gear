class AddOnSaleToProducts < ActiveRecord::Migration[5.2]
  def up
    add_column :spree_products, :on_sale, :boolean, index: true

    Spree::Product.all.each &:update_discount_attributes
  end

  def down
    remove_column :spree_products, :on_sale
  end
end
