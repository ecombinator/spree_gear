# This migration comes from spree_gear (originally 20171113120556)
# This migration comes from spree_reviews (originally 20140703200946)
class AddShowIdentifierToReviews < SpreeExtension::Migration[4.2]
  def change
    add_column :spree_reviews, :show_identifier, :boolean, default: true
    add_index :spree_reviews, :show_identifier
  end
end
