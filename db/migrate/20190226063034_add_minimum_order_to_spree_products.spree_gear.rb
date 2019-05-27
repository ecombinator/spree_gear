class AddMinimumOrderToSpreeProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_products, :minimum_order, :integer, default: 1
  end
end
