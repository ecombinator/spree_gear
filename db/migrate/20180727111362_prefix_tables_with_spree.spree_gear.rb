# This migration comes from spree_gear (originally 20180122190052)
# This migration comes from spree_comments (originally 20111123200847)
class PrefixTablesWithSpree < SpreeExtension::Migration[4.2]
  def change
    rename_table :comments, :spree_comments
    rename_table :comment_types, :spree_comment_types
  end
end
