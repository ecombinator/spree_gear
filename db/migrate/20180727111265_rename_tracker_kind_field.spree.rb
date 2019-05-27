# This migration comes from spree (originally 20170727103056)
class RenameTrackerKindField < ActiveRecord::Migration[5.1]
  def change
    unless column_exists? :spree_trackers, :engine
      rename_column :spree_trackers, :kind, :engine
    end
  end
end
