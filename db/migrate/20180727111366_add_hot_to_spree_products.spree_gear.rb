# This migration comes from spree_gear (originally 20180612153257)
class AddHotToSpreeProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_products, :hot, :boolean, default: false
  end
end
