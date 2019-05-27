# This migration comes from spree_gear (originally 20180104080956)
class CreateSpreeSliders < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_sliders do |t|
      t.string :title
      t.integer :order
      t.boolean :active, default: false, index: true
      t.integer :max_height

      t.timestamps
    end

    add_index :spree_sliders, [:order, :active]
  end
end
