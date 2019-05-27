require "pp"
require "spree_gear/importers/product_importer"
require "spree_gear/importers/product_dump"


namespace :spree_gear do
  task test: :environment do
    puts "works"
  end

  desc "Clear cache, so taxons work"
  task cache_clear: :environment do
    Rails.cache.clear
  end

  desc "Update product price attributes"
  task update_prices: :environment do
    Spree::Product.available.each &:update_discount_attributes
    Spree::Product.available.each &:update_price_ranges
  end

  desc "sends mailing to target emails"
  task :send_mailing, [:mailing_id, :email_csv] => :environment do |task, args|
    mailing = Spree::Mailing.find(args.mailing_id)
    count = 0
    File.open(args.email_csv).each do |email|
      puts "Sending to #{email}"
      mailing.send_to!([email.strip])
      count += 1
      break if Rails.env.development?
    end
  end

  namespace :woocomerce_importer do
    desc "Import products from the woocommerce importer"
    task import_products: :environment do
      importer = SpreeGear::Importers::ProductImporter.new ENV["WC_API_KEY"], ENV["WC_API_SECRET"]
      importer.import!
    end
  end

  namespace :reports do
    desc "Attmepts to reignite the cache method by rendering the totals partial"
    task visit_totals: :environment do
      include SpreeGear::Base::ViewHelpers::Reports

      puts "visiting totals report"
      ["monthly", "weekly"].each do |interval|
        ["completed", "shipped", "paid"].each do |state|
          totals_interval = interval
          totals_state = state
          totals_variants = false
          totals_ranges = send("#{totals_interval}_ranges")
          totals_cache_expires_in = 24.hours
          Spree::Admin::ReportsController.render(:totals,
            assigns: {
              totals_interval: totals_interval,
              totals_state: totals_state,
              totals_variants: totals_variants,
              totals_ranges: totals_ranges,
              totals_cache_expires_in: totals_cache_expires_in
            },
            layout: false
          )
        end
      end
      puts "done visiting totals report"
    end
  end

  namespace :product_dump do
    desc "Exports spree products, variants, taxons (but not product images) currently in the database\
      to a yml dumpfile called 'products_dump' "
    task export_products: :environment do
      importer = SpreeGear::Importers::ProductDump.new
      importer.export_products
    end

    # eg: rake "spree_gear:import_products_dump[products_dump_1539541017.yml]"
    desc "Import products, variants, taxons from generated yml file 'products_dump'"
    task :import_products,[:file_name] => :environment do |t, args|
      importer = SpreeGear::Importers::ProductDump.new
      importer.import_products(args.file_name)
    end

    # Used after importing products from the dump file, since the dump file doesnt contain images
    desc "Imports images from a folder, see source code for more info"
    task :import_images_from, [:file_name] => :environment do |t, args|
      importer = SpreeGear::Importers::ProductDump.new
      importer.import_images(args.file_name)
    end
  end

  namespace :scheduler do
    desc "Remove unavailable items from cart"
    task prune_carts: :environment do
      Spree::Order.where(state: "cart").where("updated_at < ?", 15.minutes.ago).each do |order|
        begin
          order.line_items.each do |line_item|
            next unless line_item.variant&.product&.available_on.nil? || ( line_item.variant && !line_item.variant.can_supply? )
            puts "Removing variant #{line_item.variant_id} from order #{order.number}"
            line_item.destroy!
            order.persist_totals
          end
        rescue
          puts "Order #{order.id} has corrupted items. Removing."
          order.destroy
        end
      end
    end
  end

  namespace :notifications do
    # eg: to warn customer of orders overdue for more than 48 hours, do: rake "spree_gear:cancel_and_notify_overdue_orders[48]"
    desc "Warns unpaid orders and notifies customers with mailer"
    task :warn_and_notify_overdue_orders, [:time_in_hours] => :environment do |t, args|
      if args.time_in_hours.present?
        Spree::Order.overdue(args.time_in_hours.to_i.hours.ago).map(&:warn_overdue)
      else
        Spree::Order.overdue(24.hours.ago).map(&:warn_overdue)
      end
    end
  end

  # eg: to cancel orders overdue for more than 48 hours, do: rake "spree_gear:cancel_and_notify_overdue_orders[48]"
  desc "Cancels unpaid orders and notifies customers with mailer"
  task :cancel_and_notify_overdue_orders, [:time_in_hours] => :environment do |t, args|
    if args.time_in_hours.present?
      Spree::Order.overdue(args.time_in_hours.to_i.hours.ago).map(&:cancel_overdue_and_notify!)
    else
      # default is 48 hours
      Spree::Order.overdue.map(&:cancel_overdue_and_notify!)
    end
  end
end
