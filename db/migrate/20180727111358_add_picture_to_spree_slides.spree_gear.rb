# This migration comes from spree_gear (originally 20180104105253)
class AddPictureToSpreeSlides < ActiveRecord::Migration[5.0]
  def self.up
    add_attachment :spree_slides, :picture
  end

  def self.down
    remove_attachment :spree_slides, :picture
  end
end
