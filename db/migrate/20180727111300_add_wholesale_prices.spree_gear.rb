# This migration comes from spree_gear (originally 20170324214750)
class AddWholesalePrices < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_variants, :wholesale_price, :decimal, precision: 10, scale: 2
  end
end
