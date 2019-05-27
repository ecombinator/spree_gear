# This migration comes from spree_gear (originally 20170223012171)
# This migration comes from spree_gateway (originally 20131112133401)
class MigrateStripePreferences < ActiveRecord::Migration[5.1]
  def up
    Spree::Preference.where("#{ActiveRecord::Base.connection.quote_column_name("key")} LIKE 'spree/gateway/stripe_gateway/login%'").each do |pref|
      pref.key = pref.key.gsub('login', 'secret_key')
      pref.save
    end
  end
end
