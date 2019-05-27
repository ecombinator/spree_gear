# This migration comes from spree_gear (originally 20170223012157)
# This migration comes from spree_api (originally 20131017162334)
class AddIndexToUserSpreeApiKey < ActiveRecord::Migration[5.1]
  def change
    unless defined?(User)
      add_index :spree_users, :spree_api_key
    end
  end
end
