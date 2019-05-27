# This migration comes from spree_gear (originally 20171230151629)
class AddStockedForTheWeekToProductsAndVariants < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_products, :stocked_for_the_week, :boolean, index: true
    add_column :spree_variants, :stocked_for_the_week, :boolean, index: true

    Spree::Variant.all.each do |variant|
      variant.update_stock_status
      puts "Updated stock for variant ##{variant.id} -> #{variant.stocked_for_the_week && "stocked" || "depleted"}"
    end
  end
end
