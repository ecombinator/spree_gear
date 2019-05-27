class RenamePricingColumns < ActiveRecord::Migration[5.2]
  def up
    rename_column :spree_products, :customer_lowest_price, :consumer_lowest_price
    rename_column :spree_products, :customer_highest_price, :consumer_highest_price

    Spree::Product.all.each do |product|
      product.update_price_ranges
      puts " -> updated product ##{product.id} to #{product.price_range.inspect}/#{product.wholesale_price_range.inspect}"
    end
  end

  def down
    rename_column :spree_products, :consumer_lowest_price, :customer_lowest_price
    rename_column :spree_products, :consumer_highest_price, :customer_highest_price
  end
end
