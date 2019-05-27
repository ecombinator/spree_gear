class AddPricesToSpreeProducts < ActiveRecord::Migration[5.2]
  def up
    [:customer_lowest_price,
     :customer_highest_price,
     :wholesaler_highest_price,
     :wholesaler_lowest_price ].each do |column|
      next if Spree::Product.column_names.include?(column)
      add_column :spree_products, column, :decimal, precision: 8, scale: 2
    end
    Spree::Product.all.each do |product|
      product.update_price_ranges
      puts " -> updated product ##{product.id} to #{product.price_range.inspect}/#{product.wholesale_price_range.inspect}"
    end
  end

  def down
    remove_column :spree_products, :customer_lowest_price
    remove_column :spree_products, :customer_highest_price
    remove_column :spree_products, :wholesaler_highest_price
    remove_column :spree_products, :wholesaler_lowest_price
  end
end
