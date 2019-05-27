# This migration comes from spree_gear (originally 20180725070253)
class RemoveSlidersFromSpreeSlides < ActiveRecord::Migration[5.0]
  def up
    ["title_x_position", "title_y_position", "title_link", "button_text"].each do |column_name|
      remove_column :spree_slides, column_name.to_sym if Spree::Slider.column_names.include? column_name
    end

  end

  def down
    [
      ["title_x_position", :integer], ["title_y_position", :integer],
        ["title_link", :string], ["button_text", :string]
      ].each do |column_batch|
      add_column :spree_slides, column_batch[0].to_sym, column_batch[1]
    end
  end
end
