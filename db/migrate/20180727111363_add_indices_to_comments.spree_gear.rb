# This migration comes from spree_gear (originally 20180122232832)
class AddIndicesToComments < ActiveRecord::Migration[5.0]
  def change
    add_index :spree_comments, [ :comment_type_id ]
    add_index :spree_comment_types, [:name]
    add_index :spree_comment_types, [:applies_to]
  end
end
