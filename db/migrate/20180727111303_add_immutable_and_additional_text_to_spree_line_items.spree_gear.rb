# This migration comes from spree_gear (originally 20170331200007)
class AddImmutableAndAdditionalTextToSpreeLineItems < ActiveRecord::Migration[5.1]
  def up
    add_column :spree_line_items, :immutable, :boolean
    add_column :spree_line_items, :additional_text, :string
  end

  def down
    remove_column :spree_line_items, :immutable
    remove_column :spree_line_items, :additional_text
    Spree::PromotionAction.delete_all type: 'Spree::BuyOneGetOne'
  end
end
