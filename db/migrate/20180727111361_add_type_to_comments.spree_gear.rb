# This migration comes from spree_gear (originally 20180122190051)
# This migration comes from spree_comments (originally 20100406100728)
class AddTypeToComments < SpreeExtension::Migration[4.2]
  def self.up
    add_column :comments, :comment_type_id, :integer
  end

  def self.down
    remove_column :comments, :comment_type_id
  end
end
