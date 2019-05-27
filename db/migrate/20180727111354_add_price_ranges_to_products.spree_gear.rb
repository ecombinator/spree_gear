# This migration comes from spree_gear (originally 20180101120856)
class AddPriceRangesToProducts < ActiveRecord::Migration[5.0]
  def up
    add_column :spree_products, :price_range, :string
    add_column :spree_products, :wholesale_price_range, :string

    puts "updating price ranges"

    Spree::Product.all.each do |product|
      product.update_price_ranges
      puts " -> updated product ##{product.id} to #{product.price_range.inspect}/#{product.wholesale_price_range.inspect}"
    end
  end

  def down
    remove_column :spree_products, :price_range
    remove_column :spree_products, :wholesale_price_range
  end

end
