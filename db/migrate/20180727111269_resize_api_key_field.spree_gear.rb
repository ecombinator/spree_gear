# This migration comes from spree_gear (originally 20170223012155)
# This migration comes from spree_api (originally 20120411123334)
class ResizeApiKeyField < ActiveRecord::Migration[5.1]
  def change
    unless defined?(User)
      change_column :spree_users, :api_key, :string, :limit => 48
    end
  end
end
