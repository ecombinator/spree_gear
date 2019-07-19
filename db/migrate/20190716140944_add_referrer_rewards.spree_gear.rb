# This migration comes from spree_gear (originally 20190716140944)
class AddReferrerRewards < ActiveRecord::Migration[5.2]
  def up
    add_column :spree_users, :referral_token, :string, index: true
    add_column :spree_users, :referral_order_id, :integer
    Spree::User.where(referral_token: nil).each &:generate_referral_token!
  end

  def down
    remove_column :spree_users, :referral_token, :string
    remove_column :spree_users, :referral_order_id, :integer
  end
end
