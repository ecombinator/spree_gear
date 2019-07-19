Rails.application.configure do
  config.require_documentation = ENV.fetch("REQUIRE_DOCUMENTATION", "false") == "true"

  config.current_store_id = ENV.fetch("CURRENT_STORE_ID", 1)

  config.weight_management = ENV.fetch("WEIGHT_MANAGEMENT", "on") == "on"
  config.weighty_permalinks = false

  config.contact_notification_email = ENV.fetch("CONTACT_NOTIFICATION_EMAIL", "info@test.com")
  config.default_mailing_list_email = ENV["DEFAULT_MAILING_LIST_EMAIL"]

  config.spree.promotions.actions << Spree::Promotion::Actions::BuyOneGetOne
  config.spree.promotions.rules << Spree::Promotion::Rules::TaxonTotal
  config.spree.promotions.rules << Spree::Promotion::Rules::TaxonOptionTotal
  config.spree.promotions.rules << Spree::Promotion::Rules::UserReferred
end
