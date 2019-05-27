# This migration comes from spree_gear (originally 20170329003350)
class AddAudienceToVariants < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_variants, :sold_to_consumers, :boolean,
               default: true, index: true
    add_column :spree_variants, :sold_to_wholesalers, :boolean,
               default: true, index: true
  end
end
