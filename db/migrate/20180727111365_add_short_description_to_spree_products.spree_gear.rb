# This migration comes from spree_gear (originally 20180606073747)
class AddShortDescriptionToSpreeProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_products, :short_description, :text
  end
end
