# This migration comes from spree_gear (originally 20170223012156)
# This migration comes from spree_api (originally 20120530054546)
class RenameApiKeyToSpreeApiKey < ActiveRecord::Migration[5.1]
  def change
    unless defined?(User)
      rename_column :spree_users, :api_key, :spree_api_key
    end
  end
end
