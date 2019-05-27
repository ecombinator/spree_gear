# This migration comes from spree_gear (originally 20171227235620)
class AddWooIdToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_products, :woo_id, :integer, index: true
  end
end
