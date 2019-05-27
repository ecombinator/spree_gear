# This migration comes from spree_gear (originally 20171228152208)
class CreateSpreeHomeCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_home_categories do |t|
      t.string :title
      t.integer :order

      t.timestamps
    end

    add_index :spree_home_categories, :order
  end
end
