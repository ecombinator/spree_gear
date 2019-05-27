# This migration comes from spree_gear (originally 20180103162217)
class MakeAllStockItemsNonBackorderable < ActiveRecord::Migration[5.0]
  def up
    execute "UPDATE spree_stock_items SET backorderable = false"
  end

  def down; end
end
