# This migration comes from spree_gear (originally 20180104103400)
class CreateSpreeSlides < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_slides do |t|
      t.references :slider
      t.string :title
      t.integer :title_x_position
      t.integer :title_y_position
      t.string :title_link
      t.string :button_text
      t.boolean :active, default: true, index: true

      t.timestamps
    end
  end
end
