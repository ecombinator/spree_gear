class AddDiscountAttributesToSpreeProducts < ActiveRecord::Migration[5.2]
  def up
    add_column :spree_products, :discount_amount, :float, default: 0, index: true
    add_column :spree_products, :discount_type, :string, default: "percent"

    Spree::Product.all.each &:update_discount_attributes
  end

  def down
    add_column :spree_products, :discount_amount
    add_column :spree_products, :discount_type
  end
end
