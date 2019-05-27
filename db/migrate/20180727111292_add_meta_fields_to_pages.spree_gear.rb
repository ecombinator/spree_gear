# This migration comes from spree_gear (originally 20170225225733)
# This migration comes from spree_static_content (originally 20091219021134)
class AddMetaFieldsToPages < ActiveRecord::Migration[5.1]
  def self.up
    add_column :spree_pages, :meta_keywords, :string
    add_column :spree_pages, :meta_description, :string
  end

  def self.down
  end
end
