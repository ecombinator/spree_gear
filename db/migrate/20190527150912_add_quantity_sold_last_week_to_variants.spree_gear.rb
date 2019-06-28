class AddQuantitySoldLastWeekToVariants < ActiveRecord::Migration[5.2]
  def up
    add_column :spree_variants, :quantity_sold_last_week, :integer, index: true

    Spree::Variant.all.each &:update_quantity_sold_last_week
    Spree::Variant.joins(:product).each &:update_stock_status
  end

  def down
    remove_column :spree_variants, :quantity_sold_last_week
  end
end